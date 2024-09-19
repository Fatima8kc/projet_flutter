import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/commentaires.dart';
import '../provider/commentaire_provider.dart';

class ReviewsScreen extends StatelessWidget {
  final int filmId; // Identifiant du film pour lequel on souhaite afficher les critiques

  ReviewsScreen({required this.filmId});

  final TextEditingController authorController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Critiques du Film'),
      ),
      body: Column(
        children: [
          // Formulaire pour ajouter une nouvelle critique
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Auteur',
                  ),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Votre Critique',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (authorController.text.isNotEmpty && contentController.text.isNotEmpty) {
                      final review = Commentaire(
                        author: authorController.text,
                        content: contentController.text,
                      );
                      reviewProvider.addReview(filmId, review);

                      // Efface les champs après soumission
                      authorController.clear();
                      contentController.clear();
                    }
                  },
                  child: Text('Soumettre la Critique'),
                ),
              ],
            ),
          ),

          // Afficher la liste des critiques
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, provider, child) {
                final reviews = provider.getFilmReviews(filmId);

                if (reviews.isEmpty) {
                  return Center(child: Text('Aucune critique pour ce film.'));
                }

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      title: Text(review.author),
                      subtitle: Text(review.content),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
