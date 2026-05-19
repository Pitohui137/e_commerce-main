import 'dart:typed_data';

/// Gambar yang dipilih user — kompatibel mobile & web (tanpa dart:io).
class PickedImage {
  const PickedImage({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  String get extension {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
