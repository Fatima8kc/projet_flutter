import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:film_gestion/provider/film_provider.dart';
import 'package:film_gestion/screens/detail_film.dart';
import 'package:film_gestion/screens/accueil.dart'; 

class RechercheFilmsDelegate extends SearchDelegate {
  final FilmProvider fournisseurFilm;

  RechercheFilmsDelegate(this.fournisseurFilm);

  @override
  List<Widget>? buildActions(BuildContext context) {
 
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; 
        },
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    fournisseurFilm.rechercherFilms(query);

    return Consumer<FilmProvider>(
      builder: (context, fournisseurFilm, child) {
        if (fournisseurFilm.isLoading) {
       
          return Center(child: CircularProgressIndicator());
        }

        final suggestions = fournisseurFilm.films;

        if (suggestions.isEmpty) {
          return Center(child: Text('Aucun film trouvé.'));
        }

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final film = suggestions[index];
            return ListTile(
              title: Text(film.titre), 
              subtitle: Text(film.description ?? 'Pas de description disponible.'), 
              leading: Image.network('https://image.tmdb.org/t/p/w500/${film.cheminAffiche}'), 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(film: film),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
      
        close(context, null); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), 
        );
      },
    );
  }
}
