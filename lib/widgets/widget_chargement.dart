import 'package:flutter/material.dart';

/// Widget de chargement réutilisable avec différents styles et options
class WidgetChargement extends StatefulWidget {
  /// Type de chargement à afficher
  final TypeChargement type;
  
  /// Message à afficher sous l'indicateur
  final String? message;
  
  /// Couleur de l'indicateur de chargement
  final Color? couleur;
  
  /// Taille de l'indicateur
  final double taille;
  
  /// Couleur de fond (si null, pas de fond)
  final Color? couleurFond;
  
  /// Si true, occupe tout l'écran
  final bool pleinEcran;
  
  /// Si true, affiche un overlay semi-transparent
  final bool avecOverlay;
  
  /// Opacité de l'overlay
  final double opaciteOverlay;
  
  /// Animation personnalisée
  final bool avecAnimation;
  
  /// Texte d'action secondaire (ex: "Annuler")
  final String? texteAction;
  
  /// Callback pour l'action secondaire
  final VoidCallback? onAction;

  const WidgetChargement({
    Key? key,
    this.type = TypeChargement.circulaire,
    this.message,
    this.couleur,
    this.taille = 40.0,
    this.couleurFond,
    this.pleinEcran = false,
    this.avecOverlay = false,
    this.opaciteOverlay = 0.5,
    this.avecAnimation = true,
    this.texteAction,
    this.onAction,
  }) : super(key: key);

  /// Factory pour un chargement simple
  factory WidgetChargement.simple({
    String? message,
    Color? couleur,
  }) {
    return WidgetChargement(
      type: TypeChargement.circulaire,
      message: message,
      couleur: couleur,
    );
  }

  /// Factory pour un chargement plein écran
  factory WidgetChargement.pleinEcran({
    String? message,
    Color? couleur,
    String? texteAction,
    VoidCallback? onAction,
  }) {
    return WidgetChargement(
      type: TypeChargement.circulaire,
      message: message,
      couleur: couleur,
      pleinEcran: true,
      avecOverlay: true,
      texteAction: texteAction,
      onAction: onAction,
    );
  }

  /// Factory pour un chargement avec points
  factory WidgetChargement.points({
    String? message,
    Color? couleur,
  }) {
    return WidgetChargement(
      type: TypeChargement.points,
      message: message,
      couleur: couleur,
    );
  }

  /// Factory pour un chargement linéaire
  factory WidgetChargement.lineaire({
    String? message,
    Color? couleur,
  }) {
    return WidgetChargement(
      type: TypeChargement.lineaire,
      message: message,
      couleur: couleur,
    );
  }

  /// Factory pour un chargement avec logo
  factory WidgetChargement.avecLogo({
    String? message,
    Color? couleur,
  }) {
    return WidgetChargement(
      type: TypeChargement.logo,
      message: message,
      couleur: couleur,
    );
  }

  @override
  State<WidgetChargement> createState() => _WidgetChargementState();
}

/// Types de chargement disponibles
enum TypeChargement {
  circulaire,
  lineaire,
  points,
  logo,
  pulse,
  rotation,
  vagues,
}

class _WidgetChargementState extends State<WidgetChargement>
    with TickerProviderStateMixin {
  late AnimationController _controllerPrincipal;
  late AnimationController _controllerSecondaire;
  late Animation<double> _animationRotation;
  late Animation<double> _animationPulse;
  late Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _initialiserAnimations();
  }

  void _initialiserAnimations() {
    // Animation principale (rotation, pulse, etc.)
    _controllerPrincipal = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animation secondaire (fade, scale, etc.)
    _controllerSecondaire = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animation de rotation
    _animationRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controllerPrincipal,
      curve: Curves.linear,
    ));

    // Animation de pulsation
    _animationPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controllerSecondaire,
      curve: Curves.easeInOut,
    ));

    // Animation de fade
    _animationFade = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controllerSecondaire,
      curve: Curves.easeInOut,
    ));

    if (widget.avecAnimation) {
      _demarrerAnimations();
    }
  }

  void _demarrerAnimations() {
    _controllerPrincipal.repeat();
    _controllerSecondaire.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controllerPrincipal.dispose();
    _controllerSecondaire.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contenu = _construireContenu();

    if (widget.pleinEcran) {
      return Scaffold(
        backgroundColor: widget.couleurFond ?? Colors.transparent,
        body: widget.avecOverlay
            ? Stack(
                children: [
                  // Overlay semi-transparent
                  Container(
                    color: Colors.black.withOpacity(widget.opaciteOverlay),
                  ),
                  // Contenu de chargement
                  contenu,
                ],
              )
            : contenu,
      );
    }

    return contenu;
  }

  Widget _construireContenu() {
    return Container(
      color: widget.couleurFond,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de chargement
            _construireIndicateur(),

            // Message si fourni
            if (widget.message != null) ...[
              const SizedBox(height: 24),
              _construireMessage(),
            ],

            // Action secondaire si fournie
            if (widget.texteAction != null && widget.onAction != null) ...[
              const SizedBox(height: 32),
              _construireBoutonAction(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construireIndicateur() {
    final couleur = widget.couleur ?? Theme.of(context).primaryColor;

    switch (widget.type) {
      case TypeChargement.circulaire:
        return _construireIndicateurCirculaire(couleur);
      
      case TypeChargement.lineaire:
        return _construireIndicateurLineaire(couleur);
      
      case TypeChargement.points:
        return _construireIndicateurPoints(couleur);
      
      case TypeChargement.logo:
        return _construireIndicateurLogo(couleur);
      
      case TypeChargement.pulse:
        return _construireIndicateurPulse(couleur);
      
      case TypeChargement.rotation:
        return _construireIndicateurRotation(couleur);
      
      case TypeChargement.vagues:
        return _construireIndicateurVagues(couleur);
    }
  }

  Widget _construireIndicateurCirculaire(Color couleur) {
    return SizedBox(
      width: widget.taille,
      height: widget.taille,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(couleur),
      ),
    );
  }

  Widget _construireIndicateurLineaire(Color couleur) {
    return Container(
      width: widget.taille * 3,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(couleur),
        backgroundColor: couleur.withOpacity(0.2),
      ),
    );
  }

  Widget _construireIndicateurPoints(Color couleur) {
    return AnimatedBuilder(
      animation: _controllerPrincipal,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delai = index * 0.3;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _controllerPrincipal,
              curve: Interval(delai, 0.7 + delai, curve: Curves.easeInOut),
            ));

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.scale(
                    scale: 0.5 + (animation.value * 0.5),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: couleur.withOpacity(0.3 + (animation.value * 0.7)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _construireIndicateurLogo(Color couleur) {
    return AnimatedBuilder(
      animation: _animationPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _animationPulse.value,
          child: Container(
            width: widget.taille,
            height: widget.taille,
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: couleur,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: widget.taille * 0.6,
              color: couleur,
            ),
          ),
        );
      },
    );
  }

  Widget _construireIndicateurPulse(Color couleur) {
    return AnimatedBuilder(
      animation: _animationPulse,
      builder: (context, child) {
        return Container(
          width: widget.taille,
          height: widget.taille,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle externe pulsant
              Transform.scale(
                scale: _animationPulse.value,
                child: Container(
                  width: widget.taille,
                  height: widget.taille,
                  decoration: BoxDecoration(
                    color: couleur.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Cercle interne fixe
              Container(
                width: widget.taille * 0.6,
                height: widget.taille * 0.6,
                decoration: BoxDecoration(
                  color: couleur,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construireIndicateurRotation(Color couleur) {
    return AnimatedBuilder(
      animation: _animationRotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationRotation.value * 2 * 3.14159,
          child: Container(
            width: widget.taille,
            height: widget.taille,
            decoration: BoxDecoration(
              border: Border.all(
                color: couleur.withOpacity(0.3),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(widget.taille / 2),
            ),
            child: CustomPaint(
              painter: _PeintreArc(
                couleur: couleur,
                epaisseur: 3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construireIndicateurVagues(Color couleur) {
    return AnimatedBuilder(
      animation: _controllerPrincipal,
      builder: (context, child) {
        return Container(
          width: widget.taille * 1.5,
          height: widget.taille,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final delai = index * 0.2;
              final animation = Tween<double>(
                begin: 0.3,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _controllerPrincipal,
                curve: Interval(delai, 0.8 + delai, curve: Curves.easeInOut),
              ));

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    width: 4,
                    height: widget.taille * animation.value,
                    decoration: BoxDecoration(
                      color: couleur,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _construireMessage() {
    return AnimatedBuilder(
      animation: _animationFade,
      builder: (context, child) {
        return Opacity(
          opacity: _animationFade.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.message!,
              style: TextStyle(
                color: widget.couleur?.withOpacity(0.8) ?? 
                       Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _construireBoutonAction() {
    return TextButton(
      onPressed: widget.onAction,
      style: TextButton.styleFrom(
        foregroundColor: widget.couleur ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: widget.couleur?.withOpacity(0.3) ?? 
                   Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Text(
        widget.texteAction!,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Painter personnalisé pour l'arc de chargement
class _PeintreArc extends CustomPainter {
  final Color couleur;
  final double epaisseur;

  _PeintreArc({
    required this.couleur,
    required this.epaisseur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = couleur
      ..strokeWidth = epaisseur
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - epaisseur) / 2;

    // Dessiner un arc de 270 degrés
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Commence en haut
      3.14159 * 1.5, // 270 degrés
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget de chargement pour les listes
class WidgetChargementListe extends StatelessWidget {
  final int nombreElements;
  final double hauteurElement;
  final EdgeInsets padding;

  const WidgetChargementListe({
    Key? key,
    this.nombreElements = 5,
    this.hauteurElement = 80,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: nombreElements,
      itemBuilder: (context, index) => _ElementChargement(
        hauteur: hauteurElement,
        index: index,
      ),
    );
  }
}

/// Élément de chargement shimmer pour les listes
class _ElementChargement extends StatefulWidget {
  final double hauteur;
  final int index;

  const _ElementChargement({
    required this.hauteur,
    required this.index,
  });

  @override
  State<_ElementChargement> createState() => _ElementChargementState();
}

class _ElementChargementState extends State<_ElementChargement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'animation avec un délai basé sur l'index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Container(
              height: widget.hauteur,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Avatar placeholder
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // Contenu placeholder
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          margin: const EdgeInsets.only(right: 80),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}