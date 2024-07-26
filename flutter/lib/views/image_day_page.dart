import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/image_day_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/navBar_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/nasa_image.dart';

class ImageDayPage extends StatelessWidget {
  final ImageDayController imageDayController = Get.put(ImageDayController());
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navBarController.currentIndex.value = 1;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
          iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          title: Text(
            'imageOfTheDay'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            Obx(() {
              if (imageDayController.isLoading.value) {
                return Container();
              } else {
                final image = imageDayController.imageOfTheDay.value;
                bool isFavorite = favoriteController.isFavorite(image);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      favoriteController.removeFavorite(image);
                    } else {
                      favoriteController.addFavorite(image);
                    }
                  },
                );
              }
            }),
          ],
        ),
        body: Obx(() {
          if (imageDayController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (imageDayController.imageOfTheDay.value.imageUrl.isEmpty) {
            return Center(child: Text('noImageForToday'.tr));
          } else {
            final image = imageDayController.imageOfTheDay.value;
            final locale = Get.locale?.languageCode ?? 'en';
            final formattedDate = DateFormat.yMMMMd(locale).format(DateTime.parse(image.date));
            return Stack(
              children: [
                // Imagem de fundo
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                // Conteúdo
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageZoomPage(image: image),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'imageHero',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      image.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                image.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.travel_explore, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    "clickToZoom".tr,
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "description".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                image.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

class ImageZoomPage extends StatelessWidget {
  final NasaImage image;

  ImageZoomPage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'imageHero',
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.network(
                  image.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, color: Colors.white);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}