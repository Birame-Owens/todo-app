import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../fournisseurs/fournisseur_auth.dart';
import '../../fournisseurs/fournisseur_taches.dart';
import '../../fournisseurs/fournisseur_localisation.dart';
import '../../widgets/bouton_personnalise.dart';
import '../taches/ecran_ajouter_tache.dart';
import '../taches/ecran_historique_taches.dart';
import 'composants/element_tache.dart';
import 'composants/widget_meteo.dart';
import 'composants/widget_profil.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  final TextEditingController _controllerRecherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
  }

  Future<void> _initialiserDonnees() async {
    final authProvider = context.read<FournisseurAuth>();
    final tachesProvider = context.read<FournisseurTaches>();
    final localisationProvider = context.read<FournisseurLocalisation>();

    if (authProvider.utilisateurActuel?.id != null) {
      // Charger les tâches
      await tachesProvider.chargerTaches(authProvider.utilisateurActuel!.id!);
      
      // Charger la localisation et météo
      await localisationProvider.obtenirLocalisationEtMeteo();
    }
  }

  Future<void> _changerPhotoProfil() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (image != null) {
                    context.read<FournisseurAuth>().changerPhotoProfil(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (image != null) {
                    context.read<FournisseurAuth>().changerPhotoProfil(image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _rafraichirDonnees() async {
    await _initialiserDonnees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        elevation: 0,
        actions: [
          // Bouton historique
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EcranHistoriqueTaches(),
                ),
              );
            },
          ),
          // Bouton déconnexion
          Consumer<FournisseurAuth>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirmer = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );

                  if (confirmer == true) {
                    await authProvider.deconnecter();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _rafraichirDonnees,
        child: CustomScrollView(
          slivers: [
            // En-tête avec profil et météo
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Widget profil
                    Consumer<FournisseurAuth>(
                      builder: (context, authProvider, child) {
                        return WidgetProfil(
                          utilisateur: authProvider.utilisateurActuel,
                          cheminPhotoProfil: authProvider.cheminPhotoProfil,
                          onTapPhoto: _changerPhotoProfil,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Widget météo
                    Consumer<FournisseurLocalisation>(
                      builder: (context, localisationProvider, child) {
                        return WidgetMeteo(
                          donneesMeteo: localisationProvider.donneesMeteo,
                          chargement: localisationProvider.chargement,
                          onRefresh: localisationProvider.rafraichirMeteo,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Barre de recherche
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controllerRecherche,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une tâche...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (valeur) {
                    context.read<FournisseurTaches>().rechercherTaches(valeur);
                  },
                ),
              ),
            ),

            // Liste des tâches
            Consumer<FournisseurTaches>(
              builder: (context, tachesProvider, child) {
                if (tachesProvider.chargement && tachesProvider.taches.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final tachesNonTerminees = tachesProvider.tachesNonTerminees;

                if (tachesNonTerminees.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _controllerRecherche.text.isEmpty
                                ? 'Aucune tâche en cours'
                                : 'Aucune tâche trouvée',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controllerRecherche.text.isEmpty
                                ? 'Ajoutez votre première tâche !'
                                : 'Essayez un autre terme de recherche',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tache = tachesNonTerminees[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ElementTache(
                          tache: tache,
                          onTap: () {
                            // Naviguer vers l'écran de modification
                          },
                          onToggleComplete: () async {
                            await tachesProvider.basculerStatutTache(tache);
                          },
                          onDelete: () async {
                            final confirmer = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer la tâche'),
                                content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmer == true) {
                              await tachesProvider.supprimerTache(tache);
                            }
                          },
                        ),
                      );
                    },
                    childCount: tachesNonTerminees.length,
                  ),
                );
              },
            ),

            // Espacement en bas
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      
      // Bouton flottant pour ajouter une tâche
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultat = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const EcranAjouterTache(),
            ),
          );

          // Rafraîchir si une tâche a été ajoutée
          if (resultat == true) {
            _rafraichirDonnees();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text('Ajouter une tâche'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _controllerRecherche.dispose();
    super.dispose();
  }
}