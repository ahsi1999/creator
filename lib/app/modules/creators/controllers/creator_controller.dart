import 'dart:io';
import 'package:creator/app/data/creator_model.dart';
import 'package:creator/app/data/media_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CreatorController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final creators = <Creator>[].obs;
  final isLoading = false.obs;

  Future<void> addCreator(Creator creator, selectedMedia) async {
    isLoading.value = true;
    print("addCreator called for creator: ${creator.name}");

    final mediaUrls = <String>[];

    try {
      // Ensure Firebase initialized
      await Firebase.initializeApp();

      final mediaFiles = List<MediaItem>.from(selectedMedia);
      print("Number of media files to upload: ${mediaFiles.length}");

      // 1️⃣ Immediately save creator with empty media
      final doc =
          FirebaseFirestore.instance.collection('creators').doc(creator.id);

      await doc.set({
        'id': creator.id,
        'name': creator.name,
        'designation': creator.designation,
        'about': creator.about,
        'price': creator.price,
        'media': mediaUrls, // empty initially
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("[log] Creator saved immediately with empty media.");

      Get.back();

      await fetchCreators();

      Get.snackbar('Success', 'Creator added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));

      for (var file in mediaFiles) {
        try {
          final id = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('creators/${creator.id}/$id');

          UploadTask uploadTask;
          if (kIsWeb) {
            if (file.bytes == null) continue;
            final contentType = file.name.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/jpeg';
            uploadTask = ref.putData(
                file.bytes!, SettableMetadata(contentType: contentType));
          } else {
            if (file.path == null) continue;
            uploadTask = ref.putFile(File(file.path!));
          }

          uploadTask.snapshotEvents.listen((event) {
            final progress = (event.bytesTransferred / event.totalBytes) * 100;
            print("Uploading ${file.name}: ${progress.toStringAsFixed(2)}%");
          });

          final snapshot = await uploadTask.whenComplete(() {});
          final url = await snapshot.ref.getDownloadURL();
          print("Upload completed for ${file.name}: $url");

          mediaUrls.add(url);

          await doc.update({'media': mediaUrls});
          print("Firestore media updated for ${file.name}");
        } catch (e, st) {
          print("Failed to upload ${file.name}: $e\n$st");
        }
      }

      print("All background uploads finished. Media URLs: $mediaUrls");
    } catch (e, st) {
      print("Error in addCreator: $e\n$st");
      Get.snackbar('Error', 'Failed to save creator: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
    } finally {
      isLoading.value = false;
      print("addCreator process completed for: ${creator.name}");
    }
  }

  Future<void> fetchCreators() async {
    try {
      isLoading.value = true;
      final snapshot =
          await _firestore.collection('creators').orderBy('createdAt').get();

      creators.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return Creator(
          id: data['id'],
          name: data['name'],
          designation: data['designation'],
          about: data['about'],
          price: (data['price'] ?? 0).toDouble(),
          media: List<String>.from(data['media'] ?? []),
        );
      }));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCreator(String id) async {
    try {
      await _firestore.collection('creators').doc(id).delete();
      Get.snackbar('Deleted', 'Creator removed successfully');
      fetchCreators();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }


  void editCreator(String id, Creator updated) {
    final index = creators.indexWhere((c) => c.id == id);
    if (index != -1) creators[index] = updated;
  }


  Creator? getById(String id) => creators.firstWhereOrNull((c) => c.id == id);

  @override
  void onInit() {
    super.onInit();
    fetchCreators();
  }
}
