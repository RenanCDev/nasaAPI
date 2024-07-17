import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/nasa_image.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
    final ValueNotifier<Map<String, dynamic>> tableStateNotifier = ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});
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

            tableStateNotifier.value = {
                'status': TableStatus.ready,
                'dataObjects': nasaImages,
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
