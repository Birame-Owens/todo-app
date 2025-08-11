class Constantes {
  // URL de base de l'API
  static const String urlBaseApi = 'http://192.168.1.10/todo_api/todo/';
  
  // Endpoints API
  static const String endpointConnexion = 'login';
  static const String endpointInscription = 'register';
  static const String endpointTaches = 'todos';
  static const String endpointAjouterTache = 'inserttodo';
  static const String endpointModifierTache = 'updatetodo';
  static const String endpointSupprimerTache = 'deletetodo';
  
  // Clés de stockage local
  static const String cleUtilisateurConnecte = 'utilisateur_connecte';
  static const String cleIdUtilisateur = 'id_utilisateur';
  static const String clePhotoProfil = 'photo_profil';
  static const String cleTachesLocales = 'taches_locales';
  
  // API Météo
  static const String cleApiMeteo = 'VOTRE_CLE_API_OPENWEATHER';
  static const String urlApiMeteo = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Messages d'erreur
  static const String erreurConnexionInternet = 'Pas de connexion internet';
  static const String erreurServeur = 'Erreur du serveur';
  static const String erreurAuthentification = 'Email ou mot de passe incorrect';
  
  // Messages de succès
  static const String succesConnexion = 'Connexion réussie';
  static const String succesInscription = 'Inscription réussie';
  static const String succesTacheAjoutee = 'Tâche ajoutée avec succès';
}