import 'dart:typed_data';

class Place {
  String? name;
  String? address;
  List<Uint8List?> images;

  Place({required this.name, required this.address, required this.images});
}