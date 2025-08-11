import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/service_localisation.dart';
import '../services/service_meteo.dart';

class FournisseurLocalisation with ChangeNotifier {
  Position? _positionActuelle;
  DonneesMeteo? _donneesMeteo;
  bool _chargement = false;
  String? _messageErreur;

  // Getters
  Position? get positionActuelle => _positionActuelle;
  DonneesMeteo? get donneesMeteo => _donneesMeteo;
  bool get chargement => _chargement;
  String? get messageErreur => _messageErreur;

  // Obtenir la localisation et les données météo
  Future<void> obtenirLocalisationEtMeteo() async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      // Obtenir la position
      _positionActuelle = await ServiceLocalisation.obtenirPositionActuelle();
      
      if (_positionActuelle != null) {
        // Obtenir les données météo
        _donneesMeteo = await ServiceMeteo.obtenirMeteoParCoordonnees(
          _positionActuelle!.latitude,
          _positionActuelle!.longitude,
        );
        
        if (_donneesMeteo == null) {
          _messageErreur = 'Impossible d\'obtenir les données météo';
        }
      } else {
        _messageErreur = 'Impossible d\'obtenir la localisation';
        // Essayer avec une ville par défaut (Dakar pour le Sénégal)
        _donneesMeteo = await ServiceMeteo.obtenirMeteoParVille('Dakar');
      }
    } catch (e) {
      _messageErreur = 'Erreur lors de l\'obtention de la localisation: $e';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  // Rafraîchir les données météo
  Future<void> rafraichirMeteo() async {
    if (_positionActuelle != null) {
      _chargement = true;
      notifyListeners();

      try {
        _donneesMeteo = await ServiceMeteo.obtenirMeteoParCoordonnees(
          _positionActuelle!.latitude,
          _positionActuelle!.longitude,
        );
      } catch (e) {
        _messageErreur = 'Erreur lors du rafraîchissement: $e';
      } finally {
        _chargement = false;
        notifyListeners();
      }
    } else {
      await obtenirLocalisationEtMeteo();
    }
  }

  // Effacer message d'erreur
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}