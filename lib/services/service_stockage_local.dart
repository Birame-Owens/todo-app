import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modeles/utilisateur.dart';
import '../modeles/tache.dart';
import '../utilitaires/constantes.dart';

class ServiceStockageLocal {
  static Database? _database;
  static SharedPreferences? _prefs;

  // Initialiser la base de données SQLite
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE taches_locales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_utilisateur INTEGER NOT NULL,
        contenu TEXT NOT NULL,
        date TEXT NOT NULL,
        terminee INTEGER NOT NULL,
        synchronisee INTEGER DEFAULT 0
      )
    ''');
  }

  // Initialiser SharedPreferences
  static Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Sauvegarder l'utilisateur connecté
  static Future<void> sauvegarderUtilisateur(Utilisateur utilisateur) async {
    final p = await prefs;
    await p.setString(Constantes.cleUtilisateurConnecte, jsonEncode(utilisateur.versJson()));
    if (utilisateur.id != null) {
      await p.setInt(Constantes.cleIdUtilisateur, utilisateur.id!);
    }
  }

  // Récupérer l'utilisateur connecté
  static Future<Utilisateur?> obtenirUtilisateur() async {
    final p = await prefs;
    final userData = p.getString(Constantes.cleUtilisateurConnecte);
    if (userData != null) {
      return Utilisateur.depuisJson(jsonDecode(userData));
    }
    return null;
  }

  // Sauvegarder photo de profil
  static Future<void> sauvegarderPhotoProfil(String cheminPhoto) async {
    final p = await prefs;
    await p.setString(Constantes.clePhotoProfil, cheminPhoto);
  }

  // Récupérer photo de profil
  static Future<String?> obtenirPhotoProfil() async {
    final p = await prefs;
    return p.getString(Constantes.clePhotoProfil);
  }

  // Déconnexion
  static Future<void> deconnecter() async {
    final p = await prefs;
    await p.clear();
  }

  // Sauvegarder tâche localement (hors ligne)
  static Future<void> sauvegarderTacheLocale(Tache tache) async {
    final db = await database;
    await db.insert('taches_locales', {
      'id_utilisateur': tache.idUtilisateur,
      'contenu': tache.contenu,
      'date': tache.date.toIso8601String(),
      'terminee': tache.terminee ? 1 : 0,
      'synchronisee': 0,
    });
  }

  // Récupérer tâches locales non synchronisées
  static Future<List<Tache>> obtenirTachesNonSynchronisees(int idUtilisateur) async {
    final db = await database;
    final maps = await db.query(
      'taches_locales',
      where: 'id_utilisateur = ? AND synchronisee = 0',
      whereArgs: [idUtilisateur],
    );

    return List.generate(maps.length, (i) {
      return Tache(
        id: maps[i]['id'] as int,
        idUtilisateur: maps[i]['id_utilisateur'] as int,
        contenu: maps[i]['contenu'] as String,
        date: DateTime.parse(maps[i]['date'] as String),
        terminee: (maps[i]['terminee'] as int) == 1,
      );
    });
  }

  // Marquer tâche comme synchronisée
  static Future<void> marquerTacheSynchronisee(int idTacheLocale) async {
    final db = await database;
    await db.update(
      'taches_locales',
      {'synchronisee': 1},
      where: 'id = ?',
      whereArgs: [idTacheLocale],
    );
  }

  // Récupérer toutes les tâches locales d'un utilisateur
  static Future<List<Tache>> obtenirToutesLesTachesLocales(int idUtilisateur) async {
    final db = await database;
    final maps = await db.query(
      'taches_locales',
      where: 'id_utilisateur = ?',
      whereArgs: [idUtilisateur],
    );

    return List.generate(maps.length, (i) {
      return Tache(
        id: maps[i]['id'] as int,
        idUtilisateur: maps[i]['id_utilisateur'] as int,
        contenu: maps[i]['contenu'] as String,
        date: DateTime.parse(maps[i]['date'] as String),
        terminee: (maps[i]['terminee'] as int) == 1,
      );
    });
  }
}