import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class StorageService {
  static final storageRef = FirebaseStorage.instance.ref();

  static Future<String?> uploadImageToStorage(File file) async {
    try {
      String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          storageRef.child('profile_image').child("profile_$currentTime");
      UploadTask task = ref.putFile(file);
      TaskSnapshot uploadedTask = await task;
      if (uploadedTask.state == TaskState.success) {
        return await uploadedTask.ref.getDownloadURL();
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
