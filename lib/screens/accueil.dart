import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/film_provider.dart';
import '../screens/recherche.dart';
import '../screens/favorit.dart';
import '../screens/aregarderplt.dart';
import '../screens/detail_film.dart';
import '../screens/telechargement.dart'; // Ajoute l'écran des téléchargements

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void>? _fetchFilmsFuture;

  @override
  void initState() {
    super.initState();
    // Initialiser les films à charger au démarrage de l'application
    _fetchFilmsFuture = Provider.of<FilmProvider>(context, listen: false).fetchFilms();
    
    // Charger les films téléchargés au démarrage
    Provider.of<FilmProvider>(context, listen: false).chargerFilmsTelecharge();
  }

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Films'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RechercheFilmsDelegate(filmProvider),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.watch_later),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchLaterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelechargementsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchFilmsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des films: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || filmProvider.films.isEmpty) {
            return Center(child: Text('Aucun film disponible', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7,
            ),
            itemCount: filmProvider.films.length,
            itemBuilder: (context, index) {
              final film = filmProvider.films[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(film: film),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: film.cheminAffiche != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w500/${film.cheminAffiche}',
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.movie, size: 100),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          film.titre,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          film.dateDeSortie ?? 'Date non définie',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
