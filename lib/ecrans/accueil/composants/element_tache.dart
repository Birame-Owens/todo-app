import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../modeles/tache.dart';

class ElementTache extends StatefulWidget {
  final Tache tache;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool afficherOptions;
  final bool afficherDate;
  final bool estModeHistorique;

  const ElementTache({
    Key? key,
    required this.tache,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.onEdit,
    this.afficherOptions = true,
    this.afficherDate = true,
    this.estModeHistorique = false,
  }) : super(key: key);

  @override
  State<ElementTache> createState() => _ElementTacheState();
}

class _ElementTacheState extends State<ElementTache>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _afficherActions = false;

  @override
  void initState() {
    super.initState();
    
    // Animation pour les actions de glissement
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Déterminer la couleur en fonction du statut et de la date
  Color _obtenirCouleurStatut() {
    if (widget.tache.terminee) {
      return Colors.green;
    } else if (_estEnRetard(widget.tache.date)) {
      return Colors.red;
    } else if (_estAujourdhui(widget.tache.date)) {
      return Colors.orange;
    } else if (_estDemain(widget.tache.date)) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  // Obtenir l'icône de priorité basée sur la date
  IconData _obtenirIconePriorite() {
    if (_estEnRetard(widget.tache.date) && !widget.tache.terminee) {
      return Icons.warning;
    } else if (_estAujourdhui(widget.tache.date)) {
      return Icons.today;
    } else if (_estDemain(widget.tache.date)) {
      return Icons.schedule;
    }
    return Icons.task_alt;
  }

  // Obtenir le texte de statut
  String _obtenirTexteStatut() {
    if (widget.tache.terminee) {
      return 'Terminé';
    } else if (_estEnRetard(widget.tache.date)) {
      return 'En retard';
    } else if (_estAujourdhui(widget.tache.date)) {
      return 'Aujourd\'hui';
    } else if (_estDemain(widget.tache.date)) {
      return 'Demain';
    }
    return 'À venir';
  }

  // Basculer l'affichage des actions
  void _basculerActions() {
    setState(() {
      _afficherActions = !_afficherActions;
    });
    
    if (_afficherActions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final heureFormat = DateFormat('HH:mm');
    final couleurStatut = _obtenirCouleurStatut();
    final iconeStatut = _obtenirIconePriorite();
    final texteStatut = _obtenirTexteStatut();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: widget.tache.terminee ? 1 : 3,
        shadowColor: couleurStatut.withOpacity(0.3),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.afficherOptions ? _basculerActions : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: couleurStatut.withOpacity(0.3),
                width: 2,
              ),
              gradient: widget.tache.terminee
                  ? LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[50]!,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        couleurStatut.withOpacity(0.05),
                      ],
                    ),
            ),
            child: Column(
              children: [
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Checkbox animé
                      _buildCheckboxAnime(),
                      
                      const SizedBox(width: 16),
                      
                      // Contenu de la tâche
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre de la tâche
                            _buildTitreTache(),
                            
                            const SizedBox(height: 8),
                            
                            // Informations de date et statut
                            if (widget.afficherDate) _buildInfosDateStatut(dateFormat, texteStatut, couleurStatut, iconeStatut),
                          ],
                        ),
                      ),
                      
                      // Badge de priorité
                      _buildBadgePriorite(couleurStatut, iconeStatut),
                      
                      // Menu options
                      if (widget.afficherOptions && !widget.estModeHistorique)
                        _buildMenuOptions(),
                    ],
                  ),
                ),
                
                // Actions étendues (si affichées)
                if (_afficherActions) _buildActionsEtendues(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour le checkbox animé
  Widget _buildCheckboxAnime() {
    return GestureDetector(
      onTap: widget.onToggleComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.tache.terminee ? Colors.green : _obtenirCouleurStatut(),
            width: 2.5,
          ),
          color: widget.tache.terminee ? Colors.green : Colors.transparent,
          boxShadow: widget.tache.terminee
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: widget.tache.terminee
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }

  // Widget pour le titre de la tâche
  Widget _buildTitreTache() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        decoration: widget.tache.terminee
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: Colors.grey,
        decorationThickness: 2,
        color: widget.tache.terminee
            ? Colors.grey[600]
            : _estEnRetard(widget.tache.date) && !widget.tache.terminee
                ? Colors.red[700]
                : Colors.black87,
      ),
      child: Text(
        widget.tache.contenu,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Widget pour les informations de date et statut
  Widget _buildInfosDateStatut(DateFormat dateFormat, String texteStatut, Color couleurStatut, IconData iconeStatut) {
    return Row(
      children: [
        // Icône de date
        Icon(
          Icons.calendar_today,
          size: 14,
          color: couleurStatut,
        ),
        const SizedBox(width: 4),
        
        // Date formatée
        Text(
          _estAujourdhui(widget.tache.date)
              ? 'Aujourd\'hui'
              : _estHier(widget.tache.date)
                  ? 'Hier'
                  : _estDemain(widget.tache.date)
                      ? 'Demain'
                      : dateFormat.format(widget.tache.date),
          style: TextStyle(
            fontSize: 12,
            color: couleurStatut,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Badge de statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: couleurStatut.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: couleurStatut.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconeStatut,
                size: 12,
                color: couleurStatut,
              ),
              const SizedBox(width: 4),
              Text(
                texteStatut,
                style: TextStyle(
                  fontSize: 10,
                  color: couleurStatut,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget pour le badge de priorité
  Widget _buildBadgePriorite(Color couleurStatut, IconData iconeStatut) {
    if (widget.tache.terminee) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      );
    }

    if (_estEnRetard(widget.tache.date)) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning,
          color: Colors.red,
          size: 20,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: couleurStatut.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconeStatut,
        color: couleurStatut,
        size: 20,
      ),
    );
  }

  // Widget pour le menu d'options
  Widget _buildMenuOptions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            if (widget.onEdit != null) widget.onEdit!();
            break;
          case 'delete':
            _confirmerSuppression();
            break;
          case 'toggle':
            if (widget.onToggleComplete != null) widget.onToggleComplete!();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                widget.tache.terminee ? Icons.undo : Icons.check,
                size: 18,
                color: widget.tache.terminee ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(widget.tache.terminee ? 'Marquer non terminé' : 'Marquer terminé'),
            ],
          ),
        ),
        if (widget.onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Supprimer'),
            ],
          ),
        ),
      ],
    );
  }

  // Widget pour les actions étendues
  Widget _buildActionsEtendues() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _slideAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton modifier
                    if (widget.onEdit != null)
                      _buildBoutonAction(
                        icone: Icons.edit,
                        label: 'Modifier',
                        couleur: Colors.blue,
                        onTap: () {
                          _basculerActions();
                          widget.onEdit!();
                        },
                      ),
                    
                    // Bouton basculer statut
                    _buildBoutonAction(
                      icone: widget.tache.terminee ? Icons.undo : Icons.check,
                      label: widget.tache.terminee ? 'Annuler' : 'Terminer',
                      couleur: widget.tache.terminee ? Colors.orange : Colors.green,
                      onTap: () {
                        _basculerActions();
                        if (widget.onToggleComplete != null) {
                          widget.onToggleComplete!();
                        }
                      },
                    ),
                    
                    // Bouton supprimer
                    _buildBoutonAction(
                      icone: Icons.delete,
                      label: 'Supprimer',
                      couleur: Colors.red,
                      onTap: () {
                        _basculerActions();
                        _confirmerSuppression();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget pour un bouton d'action
  Widget _buildBoutonAction({
    required IconData icone,
    required String label,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: couleur.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: couleur.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: couleur, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: couleur,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour confirmer la suppression
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

    if (confirmer == true && widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  // Méthodes utilitaires pour les dates
  bool _estAujourdhui(DateTime date) {
    final aujourd = DateTime.now();
    return date.year == aujourd.year &&
        date.month == aujourd.month &&
        date.day == aujourd.day;
  }

  bool _estHier(DateTime date) {
    final hier = DateTime.now().subtract(const Duration(days: 1));
    return date.year == hier.year &&
        date.month == hier.month &&
        date.day == hier.day;
  }

  bool _estDemain(DateTime date) {
    final demain = DateTime.now().add(const Duration(days: 1));
    return date.year == demain.year &&
        date.month == demain.month &&
        date.day == demain.day;
  }

  bool _estEnRetard(DateTime date) {
    final maintenant = DateTime.now();
    final dateSeule = DateTime(date.year, date.month, date.day);
    final maintenantSeul = DateTime(maintenant.year, maintenant.month, maintenant.day);
    return dateSeule.isBefore(maintenantSeul);
  }
}