import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/fournisseur_taches.dart';
import '../../modeles/tache.dart';
import '../../widgets/bouton_personnalise.dart';
import '../../widgets/champ_texte_personnalise.dart';

class EcranModifierTache extends StatefulWidget {
  final Tache tache;

  const EcranModifierTache({
    super.key,
    required this.tache,
  });

  @override
  State<EcranModifierTache> createState() => _EcranModifierTacheState();
}

class _EcranModifierTacheState extends State<EcranModifierTache> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controllerContenu;
  late DateTime _dateSelectionnee;
  late bool _estTerminee;

  @override
  void initState() {
    super.initState();
    _controllerContenu = TextEditingController(text: widget.tache.contenu);
    _dateSelectionnee = widget.tache.date;
    _estTerminee = widget.tache.terminee;
  }

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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _dateSelectionnee = date;
      });
    }
  }

  Future<void> _modifierTache() async {
    if (_formKey.currentState!.validate()) {
      final tachesProvider = context.read<FournisseurTaches>();

      // Créer une nouvelle tâche modifiée
      final tacheModifiee = widget.tache.copierAvec(
        contenu: _controllerContenu.text.trim(),
        date: _dateSelectionnee,
        terminee: _estTerminee,
      );

      final succes = await tachesProvider.modifierTache(tacheModifiee);

      if (mounted) {
        if (succes) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tâche modifiée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tachesProvider.messageErreur ?? 'Erreur lors de la modification'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmerSuppression() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer la tâche'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.tache.contenu,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette action ne peut pas être annulée.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer == true) {
      final tachesProvider = context.read<FournisseurTaches>();
      final succes = await tachesProvider.supprimerTache(widget.tache);

      if (mounted) {
        if (succes) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tâche supprimée avec succès !'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tachesProvider.messageErreur ?? 'Erreur lors de la suppression'),
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
      appBar: AppBar(
        title: const Text('Modifier la tâche'),
        elevation: 0,
        actions: [
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmerSuppression,
            tooltip: 'Supprimer la tâche',
          ),
        ],
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
                  'Modifier la tâche',
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

                const SizedBox(height: 24),

                // Statut terminé/non terminé
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _estTerminee ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _estTerminee ? Colors.green[200]! : Colors.orange[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut de la tâche',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _estTerminee ? Icons.check_circle : Icons.pending,
                            color: _estTerminee ? Colors.green[600] : Colors.orange[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _estTerminee ? 'Tâche terminée' : 'Tâche en cours',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _estTerminee ? Colors.green[700] : Colors.orange[700],
                              ),
                            ),
                          ),
                          Switch(
                            value: _estTerminee,
                            onChanged: (valeur) {
                              setState(() {
                                _estTerminee = valeur;
                              });
                            },
                            activeColor: Colors.green[600],
                            inactiveThumbColor: Colors.orange[600],
                            inactiveTrackColor: Colors.orange[200],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Bouton de modification
                Consumer<FournisseurTaches>(
                  builder: (context, tachesProvider, child) {
                    return BoutonPersonnalise(
                      texte: 'Enregistrer les modifications',
                      onPressed: tachesProvider.chargement ? null : _modifierTache,
                      chargement: tachesProvider.chargement,
                      icone: Icons.save,
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