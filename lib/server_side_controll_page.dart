// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'constants.dart';
import 'image_screen.dart';

class SocketIOTesting extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SocketIOTesting({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<SocketIOTesting> createState() => _SocketIOTestingState();
}

class _SocketIOTestingState extends State<SocketIOTesting> {
  //! controller variable
  late CameraController controller;
  final List<XFile?> _paths = [];
  late IO.Socket socket;
  bool showImage = false;

  @override
  void initState() {
    super.initState();
    connectToServer();
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    socket.on(
        'click-a-photo',
        (data) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("photo-clicked"))));
  }

  void connectToServer() async {
    log('connecting to server...');
    socket = IO.io(websiteURL, <String, dynamic>{
      //! use your website url or use http://localhost:3000/
      "transports": ["websocket"],
      "autoConnect": false
    });
    // ignore: await_only_futures
    await socket.connect();
    socket.onConnect((_) {
      log('connect');
    });

    socket.on('custom-event', (data) {
      String message = data[0]['message'];
      log('Event received: $message');
      _captureImage();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("photo-clicked-from-server-side")));
      setState(() {});
    });
    socket.on('disconnect', (_) => log('disconnect'));
    socket.onConnectError((data) => log(data.toString()));
    socket.onConnectTimeout((data) => log(data.toString()));
    socket.onDisconnect((_) => log('disconnect'));
  }

  Future<void> _captureImage() async {
    try {
      _paths.clear();
      XFile imageFile = await controller.takePicture();
      _paths.add(imageFile);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageScreen(
                    paths: _paths,
                    aspectRatio: controller.value.aspectRatio,
                  )));
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Socket IO Trigger")),
      body: SingleChildScrollView(
        child: Center(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ElevatedButton(
                onPressed: () {
                  socket.emit('click-photo', ['click']);
                },
                child: const Text("show snakbar")),
            Container(
              height: size.height * 0.7 + 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.grey,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: size.height * 0.7,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: AspectRatio(
                      aspectRatio: 1 / controller.value.aspectRatio,
                      child: CameraPreview(controller)),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  _captureImage();
                },
                child: const Text("Capture Image")),
            const SizedBox(
              height: 10,
            ),
          ]),
        ),
      ),
    );
  }
}
