import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadStoryCover(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final reference = _storage.ref().child('story_covers').child(fileName);

    await reference.putFile(imageFile);

    return await reference.getDownloadURL();
  }

  static Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) {
      return;
    }

    try {
      final reference = _storage.refFromURL(imageUrl);

      await reference.delete();
    } catch (_) {
      // Image may already be deleted.
    }
  }
}
