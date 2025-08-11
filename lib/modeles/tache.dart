class Tache {
  final int? id;
  final int idUtilisateur;
  final String contenu;
  final DateTime date;
  final bool terminee;

  Tache({
    this.id,
    required this.idUtilisateur,
    required this.contenu,
    required this.date,
    this.terminee = false,
  });

  Map<String, dynamic> versJson() {
  return {
    'todo_id': id?.toString(),
    'account_id': idUtilisateur.toString(),
    'todo': contenu,
    'date': date.toIso8601String().split('T')[0],
    'done': terminee ? 1 : 0,
  };
}

  factory Tache.depuisJson(Map<String, dynamic> json) {
  return Tache(
    id: json['todo_id'] ?? json['id'],
    idUtilisateur: int.parse(json['account_id'].toString()),
    contenu: json['todo'] ?? '',
    date: DateTime.parse(json['date']),
    terminee: json['done'] == 1 || json['done'] == '1' || json['done'] == true,
  );
}


  Tache copierAvec({
    int? id,
    int? idUtilisateur,
    String? contenu,
    DateTime? date,
    bool? terminee,
  }) {
    return Tache(
      id: id ?? this.id,
      idUtilisateur: idUtilisateur ?? this.idUtilisateur,
      contenu: contenu ?? this.contenu,
      date: date ?? this.date,
      terminee: terminee ?? this.terminee,
    );
  }
}