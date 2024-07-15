import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../controllers/space_controller.dart';
import '../data/dataService.dart';
import '../models/nasa_image.dart';
import 'image_details_page.dart';

MaterialColor customSwatch = MaterialColor(0xFF008080, {
  50: Color(0xFF008080),
  100: Color(0xFF008080),
  200: Color(0xFF008080),
  300: Color(0xFF008080),
  400: Color(0xFF008080),
  500: Color(0xFF008080),
  600: Color(0xFF008080),
  700: Color(0xFF008080),
  800: Color(0xFF008080),
  900: Color(0xFF008080),
});

MaterialColor customSwatchSecundary = MaterialColor(0xFFABCDEF, {
  50: Color(0xFFABCDEF),
  100: Color(0xFFABCDEF),
  200: Color(0xFFABCDEF),
  300: Color(0xFFABCDEF),
  400: Color(0xFFABCDEF),
  500: Color(0xFFABCDEF),
  600: Color(0xFFABCDEF),
  700: Color(0xFFABCDEF),
  800: Color(0xFFABCDEF),
  900: Color(0xFFABCDEF),
});

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class HomePage extends StatelessWidget {
  final SpaceController controller = Get.put(SpaceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyNewAppBar(),
      body: ValueListenableBuilder(
        valueListenable: dataService.tableStateNotifier,
        builder: (_, value, __) {
          switch (value['status']) {
            case TableStatus.idle:
              return Center(child: Text("Toque no botão de recarregar"));
            case TableStatus.loading:
              return Center(child: CircularProgressIndicator());
            case TableStatus.ready:
              var nasaImages = value['dataObjects'] as List<NasaImage>;
              return ListView.builder(
                itemCount: nasaImages.length,
                itemBuilder: (context, index) {
                  final image = nasaImages[index];
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
            case TableStatus.error:
              return Center(child: Text("Erro ao carregar os dados"));
            default:
              return Center(child: Text("Status desconhecido"));
          }
        },
      ),
      bottomNavigationBar: NewNavBar(
          itemSelectedCallback: (index) {},
          icons: [
            Icons.coffee,
            Icons.local_drink,
            Icons.public,
          ],
          iconColors: [
            Color.fromARGB(255, 255, 220, 0),
            Color.fromARGB(255, 0, 135, 0),
            Color.fromARGB(255, 255, 0, 0)
          ],
          labels: ["Cafés", "Cervejas", "Nações"]
        ),
    );
  }
}

class MyNewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SpaceController spaceController = Get.put(SpaceController());

  MyNewAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? customSwatchSecundary : customSwatch,
      leading: IconButton(
        icon: Icon(Icons.refresh),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        onPressed: () {
          spaceController.fetchNasaImages();
        },
      ),
      title: Text("Space Explorer", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 28,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)),
      centerTitle: true,
      actions: [
        Obx(() => IconButton(
          icon: Icon(
            Get.find<ThemeController>().isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          ),
          onPressed: () {
            Get.find<ThemeController>().toggleTheme();
          },
        )),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NewNavBar extends HookWidget {
  final void Function(int)? itemSelectedCallback;
  final List<IconData> icons;
  final List<Color> iconColors;
  final List<String> labels;

  NewNavBar({
    required this.icons,
    required this.iconColors,
    required this.labels,
    this.itemSelectedCallback,
  });

  @override
  Widget build(BuildContext context) {
    assert(icons.length == labels.length && icons.length == iconColors.length);
    var state = useState(1);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index){
        state.value = index;
        itemSelectedCallback?.call(index);
      }, 
      currentIndex: state.value,
      items: List.generate(icons.length, (index) {
        return BottomNavigationBarItem(
          icon: Icon(icons[index], color: iconColors[index]),
          label: labels[index],
        );
      }),
    );
  }
}
