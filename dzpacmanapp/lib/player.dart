import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(2.0),
      child: Image.asset(
        'lib/pacmanimages/pacman1nb.png'
      ),
    );
  }
}