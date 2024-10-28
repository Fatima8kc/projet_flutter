import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/film_provider.dart';
import '../screens/detail_film.dart';

class TelechargementsPage extends StatefulWidget {
  @override
  _TelechargementsPageState createState() => _TelechargementsPageState();
}

class _TelechargementsPageState extends State<TelechargementsPage> {
  @override
  void initState() {
    super.initState();
   
    Future.microtask(() {
      Provider.of<FilmProvider>(context, listen: false).chargerFilmsTelecharge();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Films Téléchargés"),
      ),
      body: Consumer<FilmProvider>(
        builder: (context, filmProvider, _) {
          final films = filmProvider.downloadedFilms;
          if (films.isEmpty) {
            return Center(child: Text("Aucun film téléchargé.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          }
          return ListView.builder(
            itemCount: films.length,
            itemBuilder: (context, index) {
              final film = films[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(8),
                  leading: film.cheminAffiche != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500/${film.cheminAffiche}',
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.movie, size: 80),
                  title: Text(
                    film.titre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(film.description ?? "Pas d'overview"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Supprimer le film'),
                            content: Text('Voulez-vous vraiment supprimer ce film des téléchargements ?'),
                            actions: [
                              TextButton(
                                child: Text('Annuler'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  filmProvider.supprimerFilmTelecharge(film);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${film.titre} a été supprimé des téléchargements')),
                                  );
                                },
                                child: Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(film: film),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
