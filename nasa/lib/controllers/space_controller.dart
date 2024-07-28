import 'package:get/get.dart';
import '../data/dataService.dart';
import '../models/nasa_image.dart';

class SpaceController extends GetxController {
  var isLoading = false.obs;
  var isTranslating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNasaImages();
  }

  Future<void> fetchNasaImages() async {
    isLoading.value = true;
    await dataService.carregarNasaImages();
    isLoading.value = false;
  }

  Future<void> updateLanguage(String languageCode) async {
    isTranslating.value = true;
    var currentImages = dataService.tableStateNotifier.value['dataObjects'] as List<NasaImage>;
    await dataService.translateImages(currentImages, languageCode);
    dataService.tableStateNotifier.value = {
      'status': TableStatus.ready,
      'dataObjects': currentImages,
    };
    isTranslating.value = false;
  }
}
