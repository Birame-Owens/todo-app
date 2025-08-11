import 'package:flutter/foundation.dart';
import '../modeles/tache.dart';
import '../services/service_api.dart';
import '../services/service_stockage_local.dart';

class FournisseurTaches with ChangeNotifier {
  List<Tache> _taches = [];
  List<Tache> _tachesFiltrees = [];
  bool _chargement = false;
  String? _messageErreur;
  String _filtreRecherche = '';

  // Getters
  List<Tache> get taches => _tachesFiltrees;
  List<Tache> get tachesTerminees => _tachesFiltrees.where((t) => t.terminee).toList();
  List<Tache> get tachesNonTerminees => _tachesFiltrees.where((t) => !t.terminee).toList();
  bool get chargement => _chargement;
  String? get messageErreur => _messageErreur;

  // Charger toutes les tâches
  Future<void> chargerTaches(int idUtilisateur) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      // Vérifier la connexion internet
      bool aConnexion = await ServiceApi.avoirConnexionInternet();
      
      if (aConnexion) {
        // Synchroniser les tâches locales non synchronisées
        await _synchroniserTachesLocales(idUtilisateur);
        
        // Récupérer les tâches depuis l'API
        final resultat = await ServiceApi.obtenirTaches(idUtilisateur);
        
        if (resultat['succes']) {
          _taches = resultat['taches'] ?? [];
        } else {
          _messageErreur = resultat['erreur'];
          // Charger les tâches locales en cas d'erreur
          _taches = await ServiceStockageLocal.obtenirToutesLesTachesLocales(idUtilisateur);
        }
      } else {
        // Mode hors ligne - charger les tâches locales
        _taches = await ServiceStockageLocal.obtenirToutesLesTachesLocales(idUtilisateur);
      }
      
      _appliquerFiltre();
    } catch (e) {
      _messageErreur = 'Erreur lors du chargement des tâches: $e';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Synchroniser les tâches locales avec le serveur
  Future<void> _synchroniserTachesLocales(int idUtilisateur) async {
    try {
      final tachesNonSynchronisees = await ServiceStockageLocal.obtenirTachesNonSynchronisees(idUtilisateur);
      
      for (Tache tache in tachesNonSynchronisees) {
        final resultat = await ServiceApi.ajouterTache(tache);
        if (resultat['succes']) {
          await ServiceStockageLocal.marquerTacheSynchronisee(tache.id!);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation: $e');
    }
  }

  // Ajouter une tâche
  Future<bool> ajouterTache({
    required int idUtilisateur,
    required String contenu,
    DateTime? date,
  }) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      final nouvelleTache = Tache(
        idUtilisateur: idUtilisateur,
        contenu: contenu,
        date: date ?? DateTime.now(),
        terminee: false,
      );

      bool aConnexion = await ServiceApi.avoirConnexionInternet();
      
      if (aConnexion) {
        // Ajouter via API
        final resultat = await ServiceApi.ajouterTache(nouvelleTache);
        if (resultat['succes']) {
          await chargerTaches(idUtilisateur); // Recharger les tâches
          return true;
        } else {
          _messageErreur = resultat['erreur'];
          // Sauvegarder localement en cas d'échec
          await ServiceStockageLocal.sauvegarderTacheLocale(nouvelleTache);
          _taches.add(nouvelleTache);
          _appliquerFiltre();
          return false;
        }
      } else {
        // Mode hors ligne
        await ServiceStockageLocal.sauvegarderTacheLocale(nouvelleTache);
        _taches.add(nouvelleTache);
        _appliquerFiltre();
        return true;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de l\'ajout de la tâche: $e';
      return false;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Modifier une tâche
  Future<bool> modifierTache(Tache tacheModifiee) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      bool aConnexion = await ServiceApi.avoirConnexionInternet();
      
      if (aConnexion) {
        final resultat = await ServiceApi.modifierTache(tacheModifiee);
        if (resultat['succes']) {
          int index = _taches.indexWhere((t) => t.id == tacheModifiee.id);
          if (index != -1) {
            _taches[index] = tacheModifiee;
            _appliquerFiltre();
          }
          return true;
        } else {
          _messageErreur = resultat['erreur'];
          return false;
        }
      } else {
        // Mode hors ligne - modifier localement
        int index = _taches.indexWhere((t) => t.id == tacheModifiee.id);
        if (index != -1) {
          _taches[index] = tacheModifiee;
          _appliquerFiltre();
        }
        return true;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de la modification: $e';
      return false;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Marquer une tâche comme terminée/non terminée
  Future<bool> basculerStatutTache(Tache tache) async {
    final tacheModifiee = tache.copierAvec(terminee: !tache.terminee);
    return await modifierTache(tacheModifiee);
  }

  // Supprimer une tâche
  Future<bool> supprimerTache(Tache tache) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      bool aConnexion = await ServiceApi.avoirConnexionInternet();
      
      if (aConnexion && tache.id != null) {
        final resultat = await ServiceApi.supprimerTache(tache.id!);
        if (resultat['succes']) {
          _taches.removeWhere((t) => t.id == tache.id);
          _appliquerFiltre();
          return true;
        } else {
          _messageErreur = resultat['erreur'];
          return false;
        }
      } else {
        // Mode hors ligne
        _taches.removeWhere((t) => t.id == tache.id);
        _appliquerFiltre();
        return true;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de la suppression: $e';
      return false;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Rechercher des tâches
  void rechercherTaches(String terme) {
    _filtreRecherche = terme.toLowerCase();
    _appliquerFiltre();
    notifyListeners();
  }

  // Appliquer le filtre de recherche
  void _appliquerFiltre() {
    if (_filtreRecherche.isEmpty) {
      _tachesFiltrees = List.from(_taches);
    } else {
      _tachesFiltrees = _taches
          .where((tache) => tache.contenu.toLowerCase().contains(_filtreRecherche))
          .toList();
    }
  }

  // Effacer message d'erreur
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}