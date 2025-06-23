import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImgService {
  ImgService._();

  static Future getGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image.path;
    }
    return null;
  }

  static Future getPhotoGallery(ValueChanged<String> onChange) async {
    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (ex) {
      debugPrint('===> trying to select image $ex');
    }
    if (file != null) {
      onChange.call(file.path);
    }
  } 
  static Future getPhotoGalleryModifiedo(ValueChanged<String> onChange, BuildContext context,{int maxSizeMB = 5}) async {
    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        // Check file size
        final File imageFile = File(file.path);
        int fileSizeInBytes = await imageFile.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

        if (fileSizeInMB > maxSizeMB) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size must be less than $maxSizeMB MB'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          //onChange.call('Image size must be less than $maxSizeMB MB');
          debugPrint('Selected image is too large: ${fileSizeInMB.toStringAsFixed(2)} MB');
         // onChange.call(""); // Return null if the image is too large
          return;
        }

        onChange.call(file.path);
      }
    } catch (ex) {
      debugPrint('===> trying to select image $ex');
    }
    if (file != null) {
      onChange.call(file.path);
    }
  }

  static Future getVideoGallery(ValueChanged<String> onChange) async {
    XFile? file;
    try {
      file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    } catch (ex) {
      debugPrint('===> trying to select image $ex');
    }
    if (file != null) {
      onChange.call(file.path);
    }
  }

  static Future getCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return image.path;
    }
    return null;
  }
}
