import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/fournisseur_auth.dart';
import '../../fournisseurs/fournisseur_taches.dart';
import '../../widgets/bouton_personnalise.dart';
import '../../widgets/champ_texte_personnalise.dart';

class EcranAjouterTache extends StatefulWidget {
  const EcranAjouterTache({super.key});

  @override
  State<EcranAjouterTache> createState() => _EcranAjouterTacheState();
}

class _EcranAjouterTacheState extends State<EcranAjouterTache> {
  final _formKey = GlobalKey<FormState>();
  final _controllerContenu = TextEditingController();
  DateTime _dateSelectionnee = DateTime.now();

  @override
  void dispose() {
    _controllerContenu.dispose();
    super.dispose();
  }

  String? _validerContenu(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Le contenu de la tâche est requis';
    }
    if (valeur.trim().length < 3) {
      return 'Le contenu doit contenir au moins 3 caractères';
    }
    return null;
  }

  Future<void> _selectionnerDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateSelectionnee,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dateSelectionnee = date;
      });
    }
  }

  Future<void> _ajouterTache() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<FournisseurAuth>();
      final tachesProvider = context.read<FournisseurTaches>();

      if (authProvider.utilisateurActuel?.id != null) {
        final succes = await tachesProvider.ajouterTache(
          idUtilisateur: authProvider.utilisateurActuel!.id!,
          contenu: _controllerContenu.text.trim(),
          date: _dateSelectionnee,
        );

        if (mounted) {
          if (succes) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tâche ajoutée avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tachesProvider.messageErreur ?? 'Erreur lors de l\'ajout'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une tâche'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nouvelle tâche',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),

                // Champ contenu de la tâche
                ChampTextePersonnalise(
                  label: 'Contenu de la tâche',
                  controller: _controllerContenu,
                  validator: _validerContenu,
                  iconePrefixe: Icons.task_alt,
                  hintText: 'Que voulez-vous accomplir ?',
                  maxLines: 3,
                ),
                
                const SizedBox(height: 24),

                // Sélecteur de date
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date d\'échéance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectionnerDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_dateSelectionnee.day.toString().padLeft(2, '0')}/'
                                '${_dateSelectionnee.month.toString().padLeft(2, '0')}/'
                                '${_dateSelectionnee.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Bouton d'ajout
                Consumer<FournisseurTaches>(
                  builder: (context, tachesProvider, child) {
                    return BoutonPersonnalise(
                      texte: 'Ajouter la tâche',
                      onPressed: tachesProvider.chargement ? null : _ajouterTache,
                      chargement: tachesProvider.chargement,
                      icone: Icons.add_task,
                      couleur: Theme.of(context).primaryColor,
                    );
                  },
                ),
                
                const SizedBox(height: 16),

                // Bouton annuler
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
