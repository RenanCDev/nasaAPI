import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/nasa_image.dart';

class SpaceController extends GetxController {
  var isLoading = true.obs;
  var nasaImages = <NasaImage>[].obs;
  final String apiKey = 't3SsIs2r23ufLDzlS9qHAZqoszVvSSwOPODaXcTc';

  @override
  void onInit() {
    super.onInit();
    fetchNasaImages();
  }

  Future<void> fetchNasaImages() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=10'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        nasaImages.value = data.map((json) => NasaImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
