import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/commentaires.dart';

class ReviewProvider with ChangeNotifier {
  Map<int, List<Commentaire>> _filmReviews = {};

  
  late String _filePath;

  ReviewProvider() {
    _init();
  }

  Future<void> _init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/film_reviews.json';
    await loadReviews();
  }

  List<Commentaire> getFilmReviews(int filmId) {
    return _filmReviews[filmId] ?? [];
  }

  void addReview(int filmId, Commentaire review) {
    if (_filmReviews[filmId] == null) {
      _filmReviews[filmId] = [];
    }
    _filmReviews[filmId]?.add(review);
    notifyListeners();
    saveReviews();
  }

  Future<void> saveReviews() async {
    String jsonString = jsonEncode(_filmReviews.map((key, value) => MapEntry(key.toString(), value.map((e) => e.toJson()).toList())));
    File file = File(_filePath);
    await file.writeAsString(jsonString);
  }

  Future<void> loadReviews() async {
    try {
      File file = File(_filePath);
      if (!await file.exists()) {
        return; // Aucun fichier trouvé
      }
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // Remplit _filmReviews à partir du JSON
      jsonMap.forEach((key, value) {
        _filmReviews[int.parse(key)] = (value as List).map((e) => Commentaire.fromJson(e)).toList();
      });
      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement des commentaires : $e");
    }
  }
}
