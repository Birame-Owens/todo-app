import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../modeles/utilisateur.dart';
import '../modeles/tache.dart';
import '../utilitaires/constantes.dart';

class ServiceApi {
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Test de connectivité
  static Future<bool> avoirConnexionInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // NOUVEAU: Inscription selon l'API du prof
  static Future<Map<String, dynamic>> inscrire({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointInscription}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': motDePasse,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          // Inscription réussie - maintenant se connecter
          return await connecter(email: email, motDePasse: motDePasse);
        } else if (data['error'] != null) {
          return {'succes': false, 'erreur': data['error']};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur inconnue'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }

  // MODIFIÉ: Connexion selon l'API du prof
  static Future<Map<String, dynamic>> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointConnexion}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': motDePasse,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          return {
            'succes': true,
            'utilisateur': Utilisateur(
              id: data['data']['account_id'],
              email: data['data']['email'],
            ),
          };
        } else if (data['error'] != null) {
          return {'succes': false, 'erreur': data['error']};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur de connexion'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }

  // MODIFIÉ: Récupérer tâches selon l'API du prof
  static Future<Map<String, dynamic>> obtenirTaches(int idUtilisateur) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointTaches}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account_id': idUtilisateur.toString(), // Le prof attend un string
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          List<Tache> taches = [];
          if (data['data'] is List) {
            taches = (data['data'] as List).map((item) => Tache.depuisJson(item)).toList();
          }
          return {'succes': true, 'taches': taches};
        } else {
          // Pas d'erreur si vide
          return {'succes': true, 'taches': []};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur lors de la récupération'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }

  // MODIFIÉ: Ajouter tâche selon l'API du prof
  static Future<Map<String, dynamic>> ajouterTache(Tache tache) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointAjouterTache}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account_id': tache.idUtilisateur.toString(),
          'date': tache.date.toIso8601String().split('T')[0],
          'todo': tache.contenu,
          'done': tache.terminee ? 1 : 0,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          return {'succes': true};
        } else if (data['error'] != null) {
          return {'succes': false, 'erreur': data['error']};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur lors de l\'ajout'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }

  // MODIFIÉ: Modifier tâche selon l'API du prof
  static Future<Map<String, dynamic>> modifierTache(Tache tache) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointModifierTache}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'todo_id': tache.id.toString(),
          'date': tache.date.toIso8601String().split('T')[0],
          'todo': tache.contenu,
          'done': tache.terminee ? 1 : 0,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          return {'succes': true};
        } else if (data['error'] != null) {
          return {'succes': false, 'erreur': data['error']};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur lors de la modification'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }

  // MODIFIÉ: Supprimer tâche selon l'API du prof
  static Future<Map<String, dynamic>> supprimerTache(int idTache) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointSupprimerTache}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'todo_id': idTache.toString(),
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          return {'succes': true};
        } else if (data['error'] != null) {
          return {'succes': false, 'erreur': data['error']};
        }
      }
      
      return {'succes': false, 'erreur': 'Erreur lors de la suppression'};
    } catch (e) {
      return {'succes': false, 'erreur': 'Erreur de connexion: $e'};
    }
  }
}