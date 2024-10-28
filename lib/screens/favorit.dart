import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/film_provider.dart'; 
import '../screens/detail_film.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FilmProvider>(context, listen: false).loadFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}')); 
        } else {
          final filmProvider = Provider.of<FilmProvider>(context); 
          return Scaffold(
            appBar: AppBar(
              title: Text('Favoris'),
            ),
            body: filmProvider.favorites.isEmpty
                ? Center(child: Text('Aucun film favori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                : ListView.builder(
                    itemCount: filmProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final film = filmProvider.favorites[index];
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
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.movie, size: 80),
                          title: Text(
                            film.titre,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(film.description ?? 'Pas de description'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Supprimer le film'),
                                    content: Text('Voulez-vous vraiment supprimer ce film de vos favoris ?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); 
                                        },
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          filmProvider.supprimerFavorit(film); 
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${film.titre} a été supprimé des favoris')),
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
                         
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen(film: film),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        }
      },
    );
  }
}
