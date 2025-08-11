import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/fournisseur_auth.dart';
import '../../widgets/bouton_personnalise.dart';
import '../../widgets/champ_texte_personnalise.dart';
import 'ecran_inscription.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _controllerEmail = TextEditingController();
  final _controllerMotDePasse = TextEditingController();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerMotDePasse.dispose();
    super.dispose();
  }

  String? _validerEmail(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return 'Email requis';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(valeur)) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validerMotDePasse(String? valeur) {
    if (valeur == null || valeur.isEmpty) {
      return 'Mot de passe requis';
    }
    if (valeur.length < 6) {
      return 'Mot de passe trop court (min 6 caractères)';
    }
    return null;
  }

  Future<void> _seConnecter() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<FournisseurAuth>();
      
      final succes = await authProvider.connecter(
        email: _controllerEmail.text.trim(),
        motDePasse: _controllerMotDePasse.text,
      );

      if (!succes && authProvider.messageErreur != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.messageErreur!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _naviguerVersInscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EcranInscription(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo/Icône de l'application
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Titre principal
                const Text(
                  'Todo App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Sous-titre
                Text(
                  'Master M1 2024-2025',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 50),
                
                // Titre de la section connexion
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Connectez-vous pour gérer vos tâches',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),

                // Champ Email
                ChampTextePersonnalise(
                  label: 'Email',
                  controller: _controllerEmail,
                  typeClavier: TextInputType.emailAddress,
                  validator: _validerEmail,
                  iconePrefixe: Icons.email_outlined,
                  hintText: 'exemple@gmail.com',
                ),
                
                const SizedBox(height: 20),

                // Champ Mot de passe
                ChampTextePersonnalise(
                  label: 'Mot de passe',
                  controller: _controllerMotDePasse,
                  motDePasse: true,
                  validator: _validerMotDePasse,
                  iconePrefixe: Icons.lock_outlined,
                  hintText: 'Votre mot de passe',
                ),
                
                const SizedBox(height: 30),

                // Bouton de connexion
                Consumer<FournisseurAuth>(
                  builder: (context, authProvider, child) {
                    return BoutonPersonnalise(
                      texte: 'Se connecter',
                      onPressed: authProvider.chargement ? null : _seConnecter,
                      chargement: authProvider.chargement,
                      icone: Icons.login,
                      couleur: Theme.of(context).primaryColor,
                    );
                  },
                ),
                
                const SizedBox(height: 30),

                // Divider avec texte
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Bouton d'inscription
                OutlinedButton.icon(
                  onPressed: _naviguerVersInscription,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Créer un compte'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // Informations de développement (optionnel - à supprimer en production)
                if (true) // Mettre à false en production
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mode Développement',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Compte de test :\nEmail: test@gmail.com\nMot de passe: motdepasse123',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}