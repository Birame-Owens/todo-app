class Utilisateur {
  final int? id;
  final String email;
  final String? photoProfil;

  Utilisateur({
    this.id,
    required this.email,
    this.photoProfil,
  });

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'email': email,
      'photo_profil': photoProfil,
    };
  }

  factory Utilisateur.depuisJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      email: json['email'],
      photoProfil: json['photo_profil'],
    );
  }

  Utilisateur copierAvec({
    int? id,
    String? email,
    String? photoProfil,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      email: email ?? this.email,
      photoProfil: photoProfil ?? this.photoProfil,
    );
  }
}