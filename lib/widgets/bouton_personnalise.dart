import 'package:flutter/material.dart';

class BoutonPersonnalise extends StatelessWidget {
  final String texte;
  final VoidCallback? onPressed;
  final bool chargement;
  final Color? couleur;
  final Color? couleurTexte;
  final double? largeur;
  final double hauteur;
  final IconData? icone;

  const BoutonPersonnalise({
    Key? key,
    required this.texte,
    this.onPressed,
    this.chargement = false,
    this.couleur,
    this.couleurTexte,
    this.largeur,
    this.hauteur = 50,
    this.icone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largeur ?? double.infinity,
      height: hauteur,
      child: ElevatedButton(
        onPressed: chargement ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur ?? Theme.of(context).primaryColor,
          foregroundColor: couleurTexte ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: chargement
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texte,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}