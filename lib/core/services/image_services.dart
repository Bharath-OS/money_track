import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageServices {
  static Future<File?> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
