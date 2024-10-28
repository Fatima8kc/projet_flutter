class Commentaire {
  final String auteur;
  final String contenu;

  Commentaire({required this.auteur, required this.contenu});
  Map<String, dynamic> toJson() {
    return {
      'auteur': auteur,
      'contenu': contenu,
    };
  }

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
      auteur: json['auteur'] ??"anonyme",
      contenu: json['contenu'] ??"aucun commentaire",
    );
  }
}
