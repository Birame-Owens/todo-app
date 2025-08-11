
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/fournisseur_auth.dart';
import '../../widgets/bouton_personnalise.dart';
import '../../widgets/champ_texte_personnalise.dart';

class EcranInscription extends StatefulWidget {
  const EcranInscription({super.key});

  @override
  State<EcranInscription> createState() => _EcranInscriptionState();
}

class _EcranInscriptionState extends State<EcranInscription> {
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

  Future<void> _sInscrire() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<FournisseurAuth>();
      
      final succes = await authProvider.inscrire(
        email: _controllerEmail.text.trim(),
        motDePasse: _controllerMotDePasse.text,
      );

      if (succes) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (authProvider.messageErreur != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.messageErreur!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                ChampTextePersonnalise(
                  label: 'Email',
                  controller: _controllerEmail,
                  typeClavier: TextInputType.emailAddress,
                  validator: _validerEmail,
                  iconePrefixe: Icons.email_outlined,
                ),
                const SizedBox(height: 24),

                ChampTextePersonnalise(
                  label: 'Mot de passe',
                  controller: _controllerMotDePasse,
                  motDePasse: true,
                  validator: _validerMotDePasse,
                  iconePrefixe: Icons.lock_outlined,
                ),
                const SizedBox(height: 32),

                Consumer<FournisseurAuth>(
                  builder: (context, authProvider, child) {
                    return BoutonPersonnalise(
                      texte: 'S\'inscrire',
                      onPressed: _sInscrire,
                      chargement: authProvider.chargement,
                      icone: Icons.person_add,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


