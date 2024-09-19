class Film {
final int id;
  final String titre;
  final String? description;
  final String? dateDeSortie;
  final double? noteMoyenne;
  final List<int> idsGenres;
  final String? cheminAffiche;
  List<Acteur>? acteurs;
  List<Realisateur>? realisateurs;
  List<BandeAnnonce>? bandesAnnonces;

  Film({
    required this.id,
    required this.titre,
    this.description,
    this.dateDeSortie,
    this.noteMoyenne,
    required this.idsGenres,
    this.cheminAffiche,
    this.acteurs,
    this.realisateurs,
    this.bandesAnnonces,
  });

  factory Film.aPartirDeJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'],
      titre: json['title'],
      description: json['overview'],
      dateDeSortie: json['release_date'],
      noteMoyenne: (json['vote_average'] as num?)?.toDouble(),
      idsGenres: List<int>.from(json['genre_ids'] ?? []),
      cheminAffiche: json['poster_path'],
      acteurs: json['credits']?['cast'] != null
          ? List<Acteur>.from(json['credits']['cast'].map((acteur) => Acteur.aPartirDeJson(acteur)))
          : [],
      realisateurs: json['credits']?['crew'] != null
          ? List<Realisateur>.from(json['credits']['crew'].where((crew) => crew['job'] == 'Director').map((realisateur) => Realisateur.aPartirDeJson(realisateur)))
          : [],
      bandesAnnonces: json['videos']?['results'] != null
          ? List<BandeAnnonce>.from(json['videos']['results'].map((bandeAnnonce) => BandeAnnonce.aPartirDeJson(bandeAnnonce)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description??'',
      'dateDeSortie': dateDeSortie??'',
      'noteMoyenne': noteMoyenne??'',
      'idsGenres': idsGenres,
      'cheminAffiche': cheminAffiche??'',
      'acteurs': acteurs != null ? acteurs!.map((acteur) => acteur.toMap()).toList() : [],
      'realisateurs': realisateurs != null ? realisateurs!.map((realisateur) => realisateur.toMap()).toList() : [],
      'bandesAnnonces': bandesAnnonces != null ? bandesAnnonces!.map((bandeAnnonce) => bandeAnnonce.toMap()).toList() : [],
    };
  }

  factory Film.aPartirDeMap(Map<String, dynamic> map) {
    return Film(
      id: map['id'],
      titre: map['title'],
      description: map['overview'],
      dateDeSortie: map['releaseDate'],
      noteMoyenne: map['voteAverage']?.toDouble(),
      idsGenres: List<int>.from(map['genreIds'] ?? []),
      cheminAffiche: map['posterPath'],
      acteurs: map['acteurs'] != null ? List<Acteur>.from(map['acteurs'].map((acteur) => Acteur.aPartirDeMap(acteur))) : [],
      realisateurs: map['realisateurs'] != null ? List<Realisateur>.from(map['realisateurs'].map((realisateur) => Realisateur.aPartirDeMap(realisateur))) : [],
      bandesAnnonces: map['bandesAnnonces'] != null ? List<BandeAnnonce>.from(map['bandesAnnonces'].map((bandeAnnonce) => BandeAnnonce.aPartirDeMap(bandeAnnonce))) : [],
    );
  }
   Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': titre,
    'overview': description ?? '', // Si la description est null, renvoie une chaîne vide
    'release_date': dateDeSortie ?? '', // Si la date est null, renvoie une chaîne vide
    'vote_average': noteMoyenne ?? 0.0, // Si la note est null, renvoie 0.0
    'genre_ids': idsGenres,
    'poster_path': cheminAffiche ?? '', // Si l'affiche est null, renvoie une chaîne vide
    'credits': {
      'cast': acteurs != null ? acteurs!.map((acteur) => acteur.toJson()).toList() : [], // Si acteurs est null, renvoie une liste vide
      'crew': realisateurs != null ? realisateurs!.map((realisateur) => realisateur.toJson()).toList() : [] // Si realisateurs est null, renvoie une liste vide
    },
    'videos': {
      'results': bandesAnnonces != null ? bandesAnnonces!.map((bandeAnnonce) => bandeAnnonce.toJson()).toList() : [] // Si bandesAnnonces est null, renvoie une liste vide
    }
  };
}

}


// Modèle pour les Acteurs
class Acteur {
  final String nom;
  final String? cheminPhoto;
  final String? personnage;

  Acteur({required this.nom, this.cheminPhoto, this.personnage});

  factory Acteur.aPartirDeJson(Map<String, dynamic> json) {
    return Acteur(
      nom: json['name'],
      cheminPhoto: json['profile_path'],
      personnage: json['character'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'cheminPhoto': cheminPhoto,
      'personnage': personnage,
    };
  }

  factory Acteur.aPartirDeMap(Map<String, dynamic> map) {
    return Acteur(
      nom: map['nom'],
      cheminPhoto: map['cheminPhoto'],
      personnage: map['personnage'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': nom,
      'profile_path': cheminPhoto,
      'character': personnage,
    };
  }
}

// Modèle pour les Réalisateurs
class Realisateur {
  final String nom;
  final String? cheminPhoto;

  Realisateur({required this.nom, this.cheminPhoto});

  factory Realisateur.aPartirDeJson(Map<String, dynamic> json) {
    return Realisateur(
      nom: json['name'],
      cheminPhoto: json['profile_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'cheminPhoto': cheminPhoto,
    };
  }

  factory Realisateur.aPartirDeMap(Map<String, dynamic> map) {
    return Realisateur(
      nom: map['nom'],
      cheminPhoto: map['cheminPhoto'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': nom,
      'profile_path': cheminPhoto,
    };
  }
}

// Modèle pour les Bandes-annonces
class BandeAnnonce {
  final String? cle;
  final String? nom;

  BandeAnnonce({this.cle, this.nom});

  factory BandeAnnonce.aPartirDeJson(Map<String, dynamic> json) {
    return BandeAnnonce(
      cle: json['key'],
      nom: json['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cle': cle,
      'nom': nom,
    };
  }

  factory BandeAnnonce.aPartirDeMap(Map<String, dynamic> map) {
    return BandeAnnonce(
      cle: map['cle'],
      nom: map['nom'],
    );
    
  }
  Map<String, dynamic> toJson() {
    return {
      'key': cle,
      'name': nom,
    };
  }
}   

