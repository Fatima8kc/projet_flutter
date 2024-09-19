import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:film_gestion/provider/film_provider.dart';
import 'package:film_gestion/screens/detail_film.dart';
import 'package:film_gestion/screens/accueil.dart'; // Importer l'écran d'accueil

class RechercheFilmsDelegate extends SearchDelegate {
  final FilmProvider fournisseurFilm;

  RechercheFilmsDelegate(this.fournisseurFilm);

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Action pour effacer le champ de recherche
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Effacer la recherche
        },
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Lancer la recherche lorsque l'utilisateur tape dans le champ
    fournisseurFilm.rechercherFilms(query);

    return Consumer<FilmProvider>(
      builder: (context, fournisseurFilm, child) {
        if (fournisseurFilm.isLoading) {
          // Afficher un indicateur de chargement pendant la recherche
          return Center(child: CircularProgressIndicator());
        }

        final suggestions = fournisseurFilm.films;

        if (suggestions.isEmpty) {
          return Center(child: Text('Aucun film trouvé.'));
        }

        // Afficher les résultats de la recherche sous forme de liste
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final film = suggestions[index];
            return ListTile(
              title: Text(film.titre), // Assurez-vous que 'title' est la bonne propriété
              subtitle: Text(film.description ?? 'Pas de description disponible.'), // Assurez-vous que 'overview' est la bonne propriété
              leading: Image.network('https://image.tmdb.org/t/p/w500/${film.cheminAffiche}'), // Assurez-vous que 'posterPath' est la bonne propriété
              onTap: () {
                // Naviguer vers les détails du film sélectionné
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
    // Utiliser le même affichage pour les suggestions et les résultats
    return buildSuggestions(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Bouton pour revenir à l'écran précédent ou à l'écran d'accueil
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // Fermer la recherche et revenir à l'écran d'accueil
        close(context, null); // Fermer la recherche
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Rediriger vers l'écran d'accueil
        );
      },
    );
  }
}
