import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/picked_image.dart';

class ImagePickerService {
  ImagePickerService(this._supabase);

  final SupabaseClient _supabase;
  final _picker = ImagePicker();

  static const _bucket = 'product-images';

  Future<PickedImage?> pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (xFile == null) return null;

      final bytes = await xFile.readAsBytes();
      final name = xFile.name.trim().isNotEmpty
          ? xFile.name
          : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return PickedImage(bytes: bytes, fileName: name);
    } catch (e) {
      throw AppException('Gagal memilih gambar: $e');
    }
  }

  Future<String> uploadImage(PickedImage image) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AppException('Anda harus login untuk mengupload foto.');
      }
      final uid = user.id;
      final ext = image.extension;
      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from(_bucket).uploadBinary(
            fileName,
            image.bytes,
            fileOptions: FileOptions(
              contentType: _mimeTypeForExtension(ext),
              upsert: false,
            ),
          );

      return _supabase.storage.from(_bucket).getPublicUrl(fileName);
    } on StorageException catch (e) {
      throw AppException('Upload gagal: ${e.message}');
    } catch (e) {
      throw AppException('Upload gagal: $e');
    }
  }

  Future<void> deleteImage(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      final bucketIdx = segments.indexOf(_bucket);
      if (bucketIdx < 0) return;
      final path = segments.sublist(bucketIdx + 1).join('/');
      await _supabase.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Best-effort
    }
  }

  static String _mimeTypeForExtension(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'gif' => 'image/gif',
      _ => 'application/octet-stream',
    };
  }
}
