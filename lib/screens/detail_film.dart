import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/film.dart';
import '../provider/film_provider.dart';
import '../screens/critique.dart';

class MovieDetailScreen extends StatefulWidget {
  final Film film;

  MovieDetailScreen({required this.film});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late final ValueNotifier<String?> _trailerKeyNotifier;
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final filmId = widget.film.id;

    _trailerKeyNotifier = ValueNotifier<String?>(null);

    filmProvider.fetchFilmDetails(filmId).then((_) {
      _loadTrailer();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des détails du film')),
      );
    });
  }

  @override
  void dispose() {
    _trailerKeyNotifier.dispose();
    _youtubePlayerController.dispose();
    super.dispose();
  }

  void _loadTrailer() {
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final trailers = filmProvider.selectedFilmTrailers;

    if (trailers.isNotEmpty) {
      final trailerKey = trailers.first.cle;
      if (trailerKey != null) {
        _trailerKeyNotifier.value = trailerKey;

        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: trailerKey,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.film.titre),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await filmProvider.chargerFilmsTelecharge();
              List<Film> films = [...filmProvider.downloadedFilms, widget.film];
              await filmProvider.enregistrerFilmsTelecharges(films);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Film téléchargé pour consultation hors ligne")),
              );
            },
          )
        ],
      ),
      body: filmProvider.selectedFilm == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.film.cheminAffiche != null)
                      CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/w500/${widget.film.cheminAffiche!}',
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    SizedBox(height: 15),
                    Text(widget.film.titre, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(widget.film.description ?? "Pas de synopsis disponible",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    SizedBox(height: 20),
                    Text("Date de sortie: ${widget.film.dateDeSortie ?? 'Non disponible'}",
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text("Évaluation: ${widget.film.noteMoyenne?.toString() ?? 'Non disponible'}/10",
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    _buildCastSection(filmProvider),
                    SizedBox(height: 20),
                    _buildDirectorsSection(filmProvider),
                    SizedBox(height: 20),
                    ValueListenableBuilder<String?>(
                      valueListenable: _trailerKeyNotifier,
                      builder: (context, trailerKey, child) {
                        if (trailerKey == null || trailerKey.isEmpty) {
                          return Text('Pas de bande-annonce disponible',
                              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bandes-annonces:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            YoutubePlayer(
                              controller: _youtubePlayerController,
                              showVideoProgressIndicator: true,
                              onReady: () {
                                print('Player is ready.');
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _youtubePlayerController.play();
                                  },
                                  icon: Icon(Icons.play_arrow),
                                  label: Text("Lire la bande-annonce"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewsScreen(filmId: widget.film.id),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.rate_review),
                                  label: Text('Voir Critiques'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 30),
                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          filmProvider.addAfavoris(widget.film);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ajouté aux favoris!')),
          );
        },
        icon: Icon(Icons.favorite, size: 20),
        label: Text('Favoris', style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          filmProvider.addAregarderPlustard(widget.film);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ajouté à "À regarder plus tard"!')),
          );
        },
        icon: Icon(Icons.watch_later, size: 20),
        label: Text('À regarder plus tard', style: TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
    ),
  ],
)

                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCastSection(FilmProvider filmProvider) {
    final cast = filmProvider.selectedFilmCast;
    if (cast.isEmpty) {
      return Container();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Casting:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cast.map((actor) {
                  return Container(
                    width: 100,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        if (actor.cheminPhoto != null)
                          CachedNetworkImage(
                            imageUrl: 'https://image.tmdb.org/t/p/w200/${actor.cheminPhoto}',
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        SizedBox(height: 5),
                        Text(actor.nom, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        if (actor.personnage != null)
                          Text(
                            '(${actor.personnage})',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildDirectorsSection(FilmProvider filmProvider) {
  final directors = filmProvider.selectedFilmDirectors;
  if (directors.isEmpty) {
    return Container();
  }

  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Réalisateurs:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: directors.map((director) {
              return Column(
                children: [
                  Container(
                    width: 100, // Largeur souhaitée pour l'image
                    height: 150, // Hauteur souhaitée pour l'image
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          'https://image.tmdb.org/t/p/w200/${director.cheminPhoto}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    director.nom,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


 }

