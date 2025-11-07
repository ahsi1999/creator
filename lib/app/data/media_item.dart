import 'dart:typed_data';

class MediaItem {
  final String name;
  final String? path; 
  final Uint8List? bytes;

  MediaItem({
    required this.name,
    this.path,
    this.bytes,
  });
}
