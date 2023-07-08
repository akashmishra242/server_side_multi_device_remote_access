import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  final List<XFile?> paths;
  final double aspectRatio;
  const ImageScreen(
      {super.key, required this.paths, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image view'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: paths.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1 / aspectRatio,
                      child: Image.file(
                        File(paths[index]!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
