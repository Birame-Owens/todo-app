import 'package:flutter/foundation.dart';
import '../modeles/utilisateur.dart';
import '../services/service_api.dart';
import '../services/service_stockage_local.dart';

class FournisseurAuth with ChangeNotifier {
  Utilisateur? _utilisateurActuel;
  bool _estConnecte = false;
  bool _chargement = false;
  String? _messageErreur;
  String? _cheminPhotoProfil;

  // Getters
  Utilisateur? get utilisateurActuel => _utilisateurActuel;
  bool get estConnecte => _estConnecte;
  bool get chargement => _chargement;
  String? get messageErreur => _messageErreur;
  String? get cheminPhotoProfil => _cheminPhotoProfil;

  // Initialiser - vérifier si un utilisateur est déjà connecté
  Future<void> initialiser() async {
    _chargement = true;
    notifyListeners();

    try {
      final utilisateur = await ServiceStockageLocal.obtenirUtilisateur();
      final photoProfil = await ServiceStockageLocal.obtenirPhotoProfil();

      if (utilisateur != null) {
        _utilisateurActuel = utilisateur;
        _estConnecte = true;
        _cheminPhotoProfil = photoProfil;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de l\'initialisation: $e';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Inscription
  Future<bool> inscrire({
    required String email,
    required String motDePasse,
  }) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      final resultat = await ServiceApi.inscrire(
        email: email,
        motDePasse: motDePasse,
      );

      if (resultat['succes']) {
        _utilisateurActuel = resultat['utilisateur'];
        _estConnecte = true;
        
        await ServiceStockageLocal.sauvegarderUtilisateur(_utilisateurActuel!);
        return true;
      } else {
        _messageErreur = resultat['erreur'];
        return false;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de l\'inscription: $e';
      return false;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> connecter({
    required String email,
    required String motDePasse,
  }) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      final resultat = await ServiceApi.connecter(
        email: email,
        motDePasse: motDePasse,
      );

      if (resultat['succes']) {
        _utilisateurActuel = resultat['utilisateur'];
        _estConnecte = true;
        
        // Sauvegarder localement
        await ServiceStockageLocal.sauvegarderUtilisateur(_utilisateurActuel!);
        
        return true;
      } else {
        _messageErreur = resultat['erreur'];
        return false;
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de la connexion: $e';
      return false;
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> deconnecter() async {
    _chargement = true;
    notifyListeners();

    try {
      await ServiceStockageLocal.deconnecter();
      _utilisateurActuel = null;
      _estConnecte = false;
      _cheminPhotoProfil = null;
      _messageErreur = null;
    } catch (e) {
      _messageErreur = 'Erreur lors de la déconnexion: $e';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Changer photo de profil
  Future<void> changerPhotoProfil(String cheminPhoto) async {
    try {
      await ServiceStockageLocal.sauvegarderPhotoProfil(cheminPhoto);
      _cheminPhotoProfil = cheminPhoto;
      notifyListeners();
    } catch (e) {
      _messageErreur = 'Erreur lors de la sauvegarde de la photo: $e';
      notifyListeners();
    }
  }

  // Effacer message d'erreur
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}