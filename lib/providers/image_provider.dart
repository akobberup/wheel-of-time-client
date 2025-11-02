import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' as picker;
import '../models/image.dart';
import '../models/enums.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Set token on API service whenever auth state changes
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return ImageService(apiService);
});

class ImageService {
  final ApiService _apiService;
  final picker.ImagePicker _picker = picker.ImagePicker();

  ImageService(this._apiService);

  Future<ImageUploadResponse?> pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image from gallery or camera
      final pickedFile = await _picker.pickImage(
        source: picker.ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Upload the image
      final file = File(pickedFile.path);
      return await _apiService.uploadImage(file, source);
    } catch (e) {
      return null;
    }
  }

  Future<ImageUploadResponse?> pickFromCamera(ImageSource source) async {
    try {
      // Pick image from camera
      final pickedFile = await _picker.pickImage(
        source: picker.ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Upload the image
      final file = File(pickedFile.path);
      return await _apiService.uploadImage(file, source);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteImage(int imageId) async {
    try {
      await _apiService.deleteImage(imageId);
      return true;
    } catch (e) {
      return false;
    }
  }

  String getImageUrl(String imagePath) {
    return _apiService.getImageUrl(imagePath);
  }

  String getThumbnailUrl(String thumbnailPath) {
    return _apiService.getThumbnailUrl(thumbnailPath);
  }
}
