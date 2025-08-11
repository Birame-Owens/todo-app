import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceLocalisation {
  // Vérifier et demander les permissions de localisation
  static Future<bool> demanderPermissions() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceActive = await Geolocator.isLocationServiceEnabled();
      if (!serviceActive) {
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtenir la position actuelle
  static Future<Position?> obtenirPositionActuelle() async {
    try {
      bool permissionAccordee = await demanderPermissions();
      if (!permissionAccordee) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      return null;
    }
  }
}