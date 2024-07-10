import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/space_controller.dart';
import 'image_details_page.dart';

class HomePage extends StatelessWidget {
  final SpaceController controller = Get.put(SpaceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exploração Espacial'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.nasaImages.length,
            itemBuilder: (context, index) {
              final image = controller.nasaImages[index];
              return ListTile(
                leading: Image.network(
                  image.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
                title: Text(image.title),
                subtitle: Text(image.date),
                onTap: () {
                  Get.to(() => ImageDetailsPage(image: image));
                },
              );
            },
          );
        }
      }),
    );
  }
}
