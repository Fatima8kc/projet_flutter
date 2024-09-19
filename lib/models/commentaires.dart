class Commentaire {
  final String author;
  final String content;

  Commentaire({
    required this.author,
    required this.content,
  });

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
      author: json['author'] ?? 'Anonyme',
      content: json['content'] ?? 'Pas de contenu',
    );
  }
}
