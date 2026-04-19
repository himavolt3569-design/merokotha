import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:merokotha/shared/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_image_provider.g.dart';

@riverpod
Future<List<String>> uploadListingImages(
  Ref ref,
  List<File> images,
  String listingId,
) async {
  final storage = ref.read(firebaseStorageProvider);
  final List<String> downloadUrls = [];

  for (int i = 0; i < images.length; i++) {
    final ref2 = storage.ref().child('listings/$listingId/image_$i.jpg');
    final task = await ref2.putFile(
      images[i],
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await task.ref.getDownloadURL();
    downloadUrls.add(url);
  }

  return downloadUrls;
}
