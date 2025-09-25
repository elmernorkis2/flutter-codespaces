import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const NavButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onTap,
        ),
        Text(label),
      ],
    );
  }
}
