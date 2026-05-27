import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadImage(File image, String path) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    final filePath = '$path/$fileName';

    await _client.storage.from('order-images').upload(
          filePath,
          image,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _client.storage.from('order-images').getPublicUrl(filePath);
  }
}
