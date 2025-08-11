import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utilitaires/constantes.dart';

class DonneesMeteo {
  final double temperature;
  final String description;
  final String icone;
  final String ville;

  DonneesMeteo({
    required this.temperature,
    required this.description,
    required this.icone,
    required this.ville,
  });

  factory DonneesMeteo.depuisJson(Map<String, dynamic> json) {
    return DonneesMeteo(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icone: json['weather'][0]['icon'],
      ville: json['name'],
    );
  }
}

class ServiceMeteo {
  // Obtenir les données météo par coordonnées
  static Future<DonneesMeteo?> obtenirMeteoParCoordonnees(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '${Constantes.urlApiMeteo}?lat=$latitude&lon=$longitude&appid=${Constantes.cleApiMeteo}&units=metric&lang=fr',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonneesMeteo.depuisJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtenir les données météo par nom de ville
  static Future<DonneesMeteo?> obtenirMeteoParVille(String nomVille) async {
    try {
      final url = Uri.parse(
        '${Constantes.urlApiMeteo}?q=$nomVille&appid=${Constantes.cleApiMeteo}&units=metric&lang=fr',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonneesMeteo.depuisJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}