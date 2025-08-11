import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import des providers
import 'fournisseurs/fournisseur_auth.dart';
import 'fournisseurs/fournisseur_taches.dart';
import 'fournisseurs/fournisseur_localisation.dart';

// Import des écrans
import 'ecrans/authentification/ecran_connexion.dart';
import 'ecrans/accueil/ecran_accueil.dart';
import 'ecrans/splash/ecran_splash.dart';

// Import des services et utilitaires
import 'services/service_stockage_local.dart';
import 'utilitaires/constantes.dart';

void main() async {
  // S'assurer que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la localisation française
  await initializeDateFormatting('fr_FR', null);
  
  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Pré-initialiser les services critiques
  await _preInitialiserServices();
  
  runApp(const MonAppTodo());
}

// Pré-initialisation des services critiques
Future<void> _preInitialiserServices() async {
  try {
    // Initialiser la base de données locale
    await ServiceStockageLocal.database;
    await ServiceStockageLocal.prefs;
    
    debugPrint('✅ Services initialisés avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation des services: $e');
  }
}

class MonAppTodo extends StatelessWidget {
  const MonAppTodo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider d'authentification (premier car les autres en dépendent)
        ChangeNotifierProvider(
          create: (_) => FournisseurAuth(),
          lazy: false, // Initialisation immédiate
        ),
        
        // Provider des tâches
        ChangeNotifierProvider(
          create: (_) => FournisseurTaches(),
        ),
        
        // Provider de localisation et météo
        ChangeNotifierProvider(
          create: (_) => FournisseurLocalisation(),
        ),
      ],
      child: MaterialApp(
        // Configuration de base
        title: 'Todo App - Master M1 2024-2025',
        debugShowCheckedModeBanner: false,
        
        // Localisation française
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // Thème de l'application
        theme: _creerThemeApplication(),
        darkTheme: _creerThemeSombre(),
        themeMode: ThemeMode.system, // Suit le thème système
        
        // Configuration des routes
        initialRoute: '/',
        routes: {
          '/': (context) => const EcranPrincipal(),
          '/connexion': (context) => const EcranConnexion(),
          '/accueil': (context) => const EcranAccueil(),
        },
        
        // Gestionnaire d'erreurs pour les routes inconnues
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const EcranErreur404(),
          );
        },
        
        // Configuration du builder pour les erreurs globales
        builder: (context, child) {
          // Gestion des erreurs d'affichage
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return EcranErreurGlobale(erreur: errorDetails);
          };
          
          return MediaQuery(
            // Désactiver les animations si nécessaire pour les performances
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }

  // Création du thème principal de l'application
  ThemeData _creerThemeApplication() {
    const couleurPrimaire = Color(0xFF2196F3); // Bleu moderne
    const couleurSecondaire = Color(0xFF03DAC6); // Cyan
    
    return ThemeData(
      // Configuration de base
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Palette de couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: couleurPrimaire,
        brightness: Brightness.light,
      ),
      
      // Couleurs principales
      primarySwatch: Colors.blue,
      primaryColor: couleurPrimaire,
      
      // Configuration de l'AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: couleurPrimaire,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Configuration des cartes
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      
      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Configuration des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: couleurPrimaire, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Configuration du FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: couleurPrimaire,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Configuration de la typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      
      // Configuration des SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[800],
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
      
      // Configuration des Dialogs
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
      ),
      
      // Configuration de la navigation bottom
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: couleurPrimaire,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Création du thème sombre
  ThemeData _creerThemeSombre() {
    const couleurPrimaire = Color(0xFF64B5F6); // Bleu plus clair pour le mode sombre
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: couleurPrimaire,
        brightness: Brightness.dark,
      ),
      
      primaryColor: couleurPrimaire,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        elevation: 4,
        color: const Color(0xFF2D2D2D),
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Écran principal avec gestion d'état d'authentification
class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  @override
  void initState() {
    super.initState();
    _initialiserApplication();
  }

  // Initialisation de l'application
  Future<void> _initialiserApplication() async {
    // Petit délai pour afficher le splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Initialiser l'authentification
      await context.read<FournisseurAuth>().initialiser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FournisseurAuth>(
      builder: (context, authProvider, child) {
        // Écran de chargement initial
        if (authProvider.chargement) {
          return const EcranSplash();
        }

        // Afficher l'erreur si nécessaire
        if (authProvider.messageErreur != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.messageErreur!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Réessayer',
                    textColor: Colors.white,
                    onPressed: () {
                      authProvider.effacerErreur();
                      _initialiserApplication();
                    },
                  ),
                ),
              );
            }
          });
        }

        // Navigation basée sur l'état d'authentification
        if (authProvider.estConnecte && authProvider.utilisateurActuel != null) {
          return const EcranAccueil();
        } else {
          return const EcranConnexion();
        }
      },
    );
  }
}

// Écran de splash/chargement
class EcranSplash extends StatelessWidget {
  const EcranSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Color(0xFF2196F3),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Nom de l'application
            const Text(
              'Todo App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Sous-titre
            const Text(
              'Master M1 2024-2025',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Indicateur de chargement
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Initialisation...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Écran d'erreur 404
class EcranErreur404 extends StatelessWidget {
  const EcranErreur404({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page non trouvée'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Page non trouvée',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'La page que vous recherchez n\'existe pas.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget d'erreur globale pour les erreurs de rendu
class EcranErreurGlobale extends StatelessWidget {
  final FlutterErrorDetails erreur;

  const EcranErreurGlobale({
    super.key,
    required this.erreur,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red[50],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              erreur.exception.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Redémarrer l'application
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Redémarrer'),
            ),
          ],
        ),
      ),
    );
  }
}