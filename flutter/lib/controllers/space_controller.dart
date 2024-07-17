import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/dataService.dart';

class SpaceController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNasaImages();
  }

  void fetchNasaImages() {
    isLoading.value = true;
    dataService.carregarNasaImages();
    isLoading.value = false;
  }
}
