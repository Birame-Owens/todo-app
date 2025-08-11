import 'package:flutter/material.dart';

class ChampTextePersonnalise extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool motDePasse;
  final TextInputType typeClavier;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? iconePrefixe;
  final int maxLines;
  final bool enabled;

  const ChampTextePersonnalise({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.motDePasse = false,
    this.typeClavier = TextInputType.text,
    this.validator,
    this.onChanged,
    this.iconePrefixe,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ChampTextePersonnalise> createState() => _ChampTextePersonnaliseState();
}

class _ChampTextePersonnaliseState extends State<ChampTextePersonnalise> {
  bool _masquerTexte = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.motDePasse && _masquerTexte,
          keyboardType: widget.typeClavier,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.motDePasse ? 1 : widget.maxLines,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.label,
            prefixIcon: widget.iconePrefixe != null
                ? Icon(widget.iconePrefixe, color: Colors.grey[600])
                : null,
            suffixIcon: widget.motDePasse
                ? IconButton(
                    icon: Icon(
                      _masquerTexte ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _masquerTexte = !_masquerTexte;
                      });
                    },
                  )
                : null,
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
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}