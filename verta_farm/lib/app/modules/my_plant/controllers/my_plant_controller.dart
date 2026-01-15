import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PlantEntry {
  PlantEntry({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shortDescription,
    required this.description,
    required this.pageType,
    required this.plantAge,
    required this.location,
    required this.variety,
    required this.notes,
    required this.sourceUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String shortDescription;
  final String description;
  final String pageType;
  final String plantAge;
  final String location;
  final String variety;
  final String notes;
  final String sourceUrl;
  final DateTime createdAt;

  factory PlantEntry.fromJson(Map<String, dynamic> json) {
    return PlantEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pageType: json['pageType'] as String? ?? '',
      plantAge: json['plantAge'] as String? ?? '',
      location: json['location'] as String? ?? '',
      variety: json['variety'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'shortDescription': shortDescription,
        'description': description,
        'pageType': pageType,
        'plantAge': plantAge,
        'location': location,
        'variety': variety,
        'notes': notes,
        'sourceUrl': sourceUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}

class MyPlantController extends GetxController {
  static const String _storageKey = 'my_plants';

  final GetStorage _storage = GetStorage();
  final plants = <PlantEntry>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlants();
  }

  void _loadPlants() {
    final raw = _storage.read<List>(_storageKey);
    if (raw == null) return;
    plants.value = raw
        .whereType<Map>()
        .map((item) => PlantEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _savePlants() {
    final payload = plants.map((p) => p.toJson()).toList();
    _storage.write(_storageKey, payload);
  }

  Future<void> addPlant(
    String name, {
    String plantAge = '',
    String location = '',
    String variety = '',
    String notes = '',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _fetchPlantInfo(cleanName);
      final entry = PlantEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['name'] as String,
        imageUrl: data['imageUrl'] as String,
        shortDescription: data['shortDescription'] as String,
        description: data['description'] as String,
        pageType: data['pageType'] as String,
        plantAge: plantAge.trim(),
        location: location.trim(),
        variety: variety.trim(),
        notes: notes.trim(),
        sourceUrl: data['sourceUrl'] as String,
        createdAt: DateTime.now(),
      );
      plants.insert(0, entry);
      _savePlants();
    } catch (e) {
      errorMessage.value = 'Failed to fetch plant details.';
    } finally {
      isLoading.value = false;
    }
  }

  void removePlant(String id) {
    plants.removeWhere((item) => item.id == id);
    _savePlants();
  }

  Future<Map<String, String>> _fetchPlantInfo(String name) async {
    final uri = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name)}',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return {
        'name': name,
        'imageUrl': '',
        'shortDescription': 'No short description available.',
        'description': 'No details found for this plant.',
        'pageType': '',
        'sourceUrl': '',
      };
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final title = (json['title'] as String?) ?? name;
    final shortDescription = (json['description'] as String?) ?? '';
    final extract = (json['extract'] as String?) ??
        'No details found for this plant.';
    final pageType = (json['type'] as String?) ?? '';
    final imageUrl = (json['thumbnail']?['source'] as String?) ?? '';
    final sourceUrl =
        (json['content_urls']?['desktop']?['page'] as String?) ?? '';

    return {
      'name': title,
      'imageUrl': imageUrl,
      'shortDescription': shortDescription,
      'description': extract,
      'pageType': pageType,
      'sourceUrl': sourceUrl,
    };
  }
}

