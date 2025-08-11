import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/fournisseur_taches.dart';
import '../accueil/composants/element_tache.dart';

class EcranHistoriqueTaches extends StatefulWidget {
  const EcranHistoriqueTaches({super.key});

  @override
  State<EcranHistoriqueTaches> createState() => _EcranHistoriqueTachesState();
}

class _EcranHistoriqueTachesState extends State<EcranHistoriqueTaches> {
  final TextEditingController _controllerRecherche = TextEditingController();

  @override
  void dispose() {
    _controllerRecherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des tâches'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controllerRecherche,
              decoration: InputDecoration(
                hintText: 'Rechercher dans l\'historique...',
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

          // Statistiques
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Consumer<FournisseurTaches>(
              builder: (context, tachesProvider, child) {
                final tachesTerminees = tachesProvider.tachesTerminees;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${tachesTerminees.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Tâches terminées',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.green[300],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 32,
                          color: Colors.green[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Félicitations !',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Liste des tâches terminées
          Expanded(
            child: Consumer<FournisseurTaches>(
              builder: (context, tachesProvider, child) {
                if (tachesProvider.chargement && tachesProvider.taches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tachesTerminees = tachesProvider.tachesTerminees;

                if (tachesTerminees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _controllerRecherche.text.isEmpty
                              ? 'Aucune tâche terminée'
                              : 'Aucune tâche trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controllerRecherche.text.isEmpty
                              ? 'Terminez quelques tâches pour voir l\'historique'
                              : 'Essayez un autre terme de recherche',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tachesTerminees.length,
                  itemBuilder: (context, index) {
                    final tache = tachesTerminees[index];
                    return ElementTache(
                      tache: tache,
                      estModeHistorique: true,
                      afficherOptions: false,
                      onToggleComplete: () async {
                        await tachesProvider.basculerStatutTache(tache);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
