// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/nasa_image.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
  int _selectedQuantity = 10;

  void setSelectedQuantity(int quantity) {
    _selectedQuantity = quantity;
  }

  void carregarNasaImages() async {
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
}

final dataService = DataService();
