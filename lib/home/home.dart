import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var key = GlobalKey();
  XFile? compressedImage;
  File? image;

  Future<void> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath, outPath,
        minWidth: 1000, minHeight: 1000, quality: 70);
  }

  Future<void> _saveLocalImage() async {
    try {
      GallerySaver.saveImage(compressedImage!.path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Image Compressed and  Saved to Gallery!")));
      debugPrint(compressedImage!.path);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error occurred. Try again!")));
    }
  }

  Future<File> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      File pickedFile = File(file.path!);
      await compressImage(pickedFile);
      return File(compressedImage!.path);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No file picked!")));

      throw Exception('No file picked');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _pickFile().then((compressedFile) {
                  setState(() {
                    image = compressedFile;
                  });
                }).catchError((error) {
                  debugPrint('Error: $error');
                });
              },
              child: const Text('Pick a File'),
            ),
          ),
          SizedBox(
            height: 500,
            width: 300,
            child: image != null
                ? Column(children: [
                    Image.file(
                      image!,
                      width: 300,
                      height: 400,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: _saveLocalImage,
                          child: const Text("Download")),
                    )
                  ])
                : const Center(child: Text('No image selected')),
          )
        ],
      )),
    );
  }
}
