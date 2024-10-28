import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/commentaires.dart';
import '../provider/commentaire_provider.dart';

class ReviewsScreen extends StatelessWidget {
  final int filmId; 

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
                        auteur: authorController.text,
                        contenu: contentController.text,
                      );
                      reviewProvider.addReview(filmId, review);

                      
                      authorController.clear();
                      contentController.clear();
                    }
                  },
                  child: Text('Soumettre la Critique'),
                ),
              ],
            ),
          ),

         
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
                      title: Text(review.auteur),
                      subtitle: Text(review.contenu),
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
