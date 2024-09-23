import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/film.dart';
import '../models/commentaires.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class FilmProvider with ChangeNotifier {
  final _apiKey = '0f720f2af70724231b5c651f89e57aac';
  List<Film> _films = [];
  List<Film> _favorites = [];
  List<Film> _watchLater = [];
  List<Commentaire> _commentaires = [];
  Film? _filmSelectionne;
  List<BandeAnnonce> _selectedFilmTrailers = []; // Liste pour les trailers
  List<Film> _filmTelecharge = [];


  List<Film> get films => _films;
  List<Film> get favorites => _favorites;
  List<Film> get watchLater => _watchLater;
  List<Commentaire> get reviews => _commentaires;
  Film? get selectedFilm => _filmSelectionne;
  List<BandeAnnonce> get selectedFilmTrailers => _selectedFilmTrailers;
  List<Acteur> get selectedFilmCast => _filmSelectionne?.acteurs ?? [];
  List<Realisateur> get selectedFilmDirectors => _filmSelectionne?.realisateurs ?? [];
  // Accéder aux films téléchargés
  List<Film> get downloadedFilms => _filmTelecharge;


  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<List<Film>> fetchFilms() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=$_apiKey&language=fr-FR'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched films: $data');

        final List<dynamic> filmsJson = data['results'];
        if (filmsJson.isEmpty) {
          print('No films found.');
        }
        _films = filmsJson.map((json) => Film.aPartirDeJson(json)).toList();
        notifyListeners();
        return _films;
      } else {
        throw Exception('Failed to load films');
      }
    } catch (error) {
      print('Error fetching films: $error');
      throw Exception('Failed to load films: $error');
    }
  }

  Future<void> rechercherFilms(String query) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final url = 'https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query&language=fr-FR';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Données reçues: $data");

        if (data['results'] != null && data['results'] is List) {
          _films = (data['results'] as List).map((filmData) => Film.aPartirDeJson(filmData)).toList();
        } else {
          _films = [];
        }
      } else {
        _errorMessage = 'Erreur de serveur: ${response.statusCode}';
        _films = [];
      }
    } catch (error) {
      print("Erreur lors de la récupération des films: $error");
      _errorMessage = 'Erreur lors de la récupération des films: $error';
      _films = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



Future<void> fetchFilmDetails(int movieId) async {
  try {
    // Démarre le chargement
    _isLoading = true;
    notifyListeners(); // Met à jour l'interface utilisateur pour indiquer le début du chargement

    // Requête pour récupérer les détails du film
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&append_to_response=credits,videos&language=fr-FR'),
    );

    if (response.statusCode == 200) {
      final filmJson = jsonDecode(response.body);

      // Vérifie si les données sont disponibles
      if (filmJson == null) {
        throw Exception('Film data is null');
      }

      // Instancie le film sélectionné
      _filmSelectionne = Film.aPartirDeJson(filmJson);

      // Récupère les bandes-annonces
      final trailersResponse = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$_apiKey&language=fr-FR'),
      );
      if (trailersResponse.statusCode == 200) {
        final trailersJson = jsonDecode(trailersResponse.body)['results'] as List? ?? [];
        _selectedFilmTrailers = trailersJson.map((trailer) => BandeAnnonce.aPartirDeJson(trailer)).toList();
      } else {
        _selectedFilmTrailers = [];
      }

      // Récupère les crédits (acteurs et réalisateurs)
      final creditsJson = filmJson['credits'] ?? {};
      print('Credits JSON: ${jsonEncode(creditsJson)}'); // Imprime les crédits pour vérification

      final castJson = creditsJson['cast'] as List? ?? [];
      final crewJson = creditsJson['crew'] as List? ?? [];

      if (_filmSelectionne != null) {
        _filmSelectionne!.acteurs = castJson.map((castMember) => Acteur.aPartirDeJson(castMember)).toList();
        _filmSelectionne!.realisateurs = crewJson
            .where((crewMember) => crewMember['job'] == 'Director')
            .map((director) => Realisateur.aPartirDeJson(director))
            .toList();
      }

      print('Nombre d\'acteurs: ${_filmSelectionne!.acteurs?.length}');
      print('Nombre de réalisateurs: ${_filmSelectionne!.realisateurs?.length}');

      // Fin du chargement et mise à jour de l'interface utilisateur
      _isLoading = false;
      notifyListeners();
    } else {
      throw Exception('Failed to load film details');
    }
  } catch (error) {
    print("Erreur lors de la récupération des détails du film: $error");
    _isLoading = false; // Assurez-vous de changer l'état même en cas d'erreur
    notifyListeners();
  }
}


Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = _favorites.map((film) => jsonEncode(film.toJson())).toList();
    await prefs.setStringList('favorites', favoritesJson);
  }

    Future<void> loadFavorites() async {
    print('Chargement des favoris...');
    try {
      await Future.delayed(Duration(seconds: 1));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? favoritesJson = prefs.getStringList('favorites');
      if (favoritesJson != null) {
        _favorites = favoritesJson.map((jsonStr) => Film.aPartirDeJson(jsonDecode(jsonStr))).toList();
      }
      notifyListeners();
    } catch (e) {
      print('Erreur de chargement: $e');
      throw e;
    }
  }


  Future<void> saveWatchLater() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchLaterJson = _watchLater.map((film) => jsonEncode(film.toJson())).toList();
    await prefs.setStringList('watchLater', watchLaterJson);
  }

  Future<void> loadWatchLater() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? watchLaterJson = prefs.getStringList('watchLater');
    if (watchLaterJson != null) {
      _watchLater = watchLaterJson.map((jsonStr) => Film.aPartirDeJson(jsonDecode(jsonStr))).toList();
    }
    notifyListeners();
  }
  Future<void> supprimerFavorit(Film film) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoritesJson = prefs.getStringList('favorites');
  
  if (favoritesJson != null) {
    List<Film> favorites = favoritesJson.map((jsonStr) => Film.aPartirDeJson(jsonDecode(jsonStr))).toList();
    favorites.removeWhere((f) => f.id == film.id); // Assurez-vous que Film a un identifiant unique

    List<String> updatedFavoritesJson = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList('favorites', updatedFavoritesJson);
  }
  notifyListeners();
}
Future<void> supprimerRegarderPlustard(Film film) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? watchLaterJson = prefs.getStringList('watchLater');

  if (watchLaterJson != null) {
    List<Film> watchLater = watchLaterJson.map((jsonStr) => Film.aPartirDeJson(jsonDecode(jsonStr))).toList();
    watchLater.removeWhere((f) => f.id == film.id); // Assurez-vous que Film a un identifiant unique

    List<String> updatedWatchLaterJson = watchLater.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList('watchLater', updatedWatchLaterJson);
  }
  notifyListeners();
}

  void addAfavoris(Film film) {
    _favorites.add(film);
      saveFavorites();// Sauvegarder les favoris après l'ajout
    notifyListeners();
  
  }

  void addAregarderPlustard(Film film) {
    _watchLater.add(film);
    saveWatchLater(); // Sauvegarder la liste 'À regarder plus tard' après l'ajout
    notifyListeners();
  }



  Future<void> initFavoritesAndWatchLater() async {
    await loadFavorites();
    await loadWatchLater();
  }

Future<void> enregistrerFilmsTelecharges(List<Film> films) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/downloaded_films.json');
  
  // Conversion des films en JSON en utilisant toJson()
  String jsonString = jsonEncode(films.map((film) => film.toJson()).toList());
  
  // Écriture du JSON dans le fichier
  await file.writeAsString(jsonString);
  
  
}


Future<void> chargerFilmsTelecharge() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/downloaded_films.json');
    
    // Vérification de l'existence du fichier
    if (!await file.exists()) {
      print("Aucun fichier trouvé.");
      return;
    }

    // Lecture du fichier JSON
    String jsonString = await file.readAsString();
    
    // Décodage du JSON en liste d'objets
    List<dynamic> jsonList = jsonDecode(jsonString);

    // Conversion des objets JSON en instances de Film
    _filmTelecharge = jsonList.map((json) => Film.aPartirDeJson(json)).toList().cast<Film>();

    // Mise à jour de l'état pour notifier l'UI
    notifyListeners();
  } catch (e) {
    print("Erreur lors de la lecture des films téléchargés : $e");
  }
}
Future<void> supprimerFilmTelecharge(Film film) async {
  _filmTelecharge.remove(film);
  await enregistrerFilmsTelecharges(_filmTelecharge);
  notifyListeners();
}

 

}
