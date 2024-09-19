import 'package:flutter/material.dart';
import '../models/commentaires.dart';

class ReviewProvider with ChangeNotifier {
 Map<int, List<Commentaire>> _filmReviews = {};

  List<Commentaire> getFilmReviews(int filmId) {
    return _filmReviews[filmId] ?? [];
  }

  void addReview(int filmId, Commentaire review) {
    if (_filmReviews[filmId] == null) {
      _filmReviews[filmId] = [];
    }
    _filmReviews[filmId]?.add(review);
    notifyListeners();
  }
}

