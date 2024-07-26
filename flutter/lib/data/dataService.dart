import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nasa_image.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
  int _selectedQuantity = 10;
  final String _googleTranslateApiKey = 'AIzaSyDFOl_kuFleMqKRAnvE8McG6XY2JKcxZVw';
  Map<String, Map<String, String>> _translationCache = {};

  DataService() {
    _loadTranslationCache();
  }

  void setSelectedQuantity(int quantity) {
    _selectedQuantity = quantity;
  }

  Future<void> carregarNasaImages() async {
    var nasaUri = Uri(
      scheme: 'https',
      host: 'api.nasa.gov',
      path: 'planetary/apod',
      queryParameters: {
        'api_key': 't3SsIs2r23ufLDzlS9qHAZqoszVvSSwOPODaXcTc',
        'count': '$_selectedQuantity'
      },
    );

    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': []
    };

    try {
      var jsonString = await http.read(nasaUri);
      var nasaJson = jsonDecode(jsonString);

      var nasaImages = nasaJson.map<NasaImage>((json) => NasaImage.fromJson(json)).toList();

      // Filtrar imagens válidas (png, gif, jpg, jpeg)
      var validImages = nasaImages.where((image) {
        String extension = image.imageUrl.split('.').last.toLowerCase();
        return extension == 'png' || extension == 'gif' || extension == 'jpg' || extension == 'jpeg';
      }).toList();

      // Caso não haja imagens suficientes, solicitar mais até atingir a quantidade necessária
      while (validImages.length < _selectedQuantity) {
        var additionalJsonString = await http.read(nasaUri);
        var additionalNasaJson = jsonDecode(additionalJsonString);

        var additionalNasaImages = additionalNasaJson.map<NasaImage>((json) => NasaImage.fromJson(json)).toList();

        var additionalValidImages = additionalNasaImages.where((image) {
          String extension = image.imageUrl.split('.').last.toLowerCase();
          return extension == 'png' || extension == 'gif' || extension == 'jpg' || extension == 'jpeg';
        }).toList();

        validImages.addAll(additionalValidImages);
      }

      // Manter apenas a quantidade necessária de imagens
      validImages = validImages.take(_selectedQuantity).toList();

      await translateImages(validImages, Get.locale?.languageCode ?? 'en');

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': validImages,
      };
    } catch (err) {
      tableStateNotifier.value = {
        'status': TableStatus.error,
        'dataObjects': []
      };
    }
  }

  Future<void> translateImages(List<NasaImage> images, String targetLanguage) async {
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      if (_translationCache.containsKey(image.title) && _translationCache[image.title]!.containsKey(targetLanguage)) {
        images[i] = NasaImage(
          title: _translationCache[image.title]![targetLanguage]!,
          date: image.date,
          description: _translationCache[image.description]![targetLanguage]!,
          imageUrl: image.imageUrl,
        );
      } else {
        final translatedTitle = await _translateText(image.title, targetLanguage);
        final translatedDescription = await _translateText(image.description, targetLanguage);

        images[i] = NasaImage(
          title: translatedTitle,
          date: image.date,
          description: translatedDescription,
          imageUrl: image.imageUrl,
        );

        _translationCache.putIfAbsent(image.title, () => {})[targetLanguage] = translatedTitle;
        _translationCache.putIfAbsent(image.description, () => {})[targetLanguage] = translatedDescription;
        
        await _saveTranslationCache();
      }
    }
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    try {
      final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2')
            .replace(queryParameters: {
              'q': text,
              'target': targetLanguage,
              'key': _googleTranslateApiKey,
            }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        return text; // Retorna o texto original em caso de falha na tradução
      }
    } catch (e) {
      return text; // Retorna o texto original em caso de exceção
    }
  }

  Future<void> _loadTranslationCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('translationCache');
    if (cacheString != null) {
      _translationCache = Map<String, Map<String, String>>.from(jsonDecode(cacheString));
    }
  }

  Future<void> _saveTranslationCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = jsonEncode(_translationCache);
    await prefs.setString('translationCache', cacheString);
  }
}

final dataService = DataService();
