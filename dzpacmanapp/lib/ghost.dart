import 'package:flutter/material.dart';

class MyGhost extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(2.0),
      child: Image.asset(
        'lib/pacmanimages/pacmanghostnb.png'
      ),
    );
  }
}