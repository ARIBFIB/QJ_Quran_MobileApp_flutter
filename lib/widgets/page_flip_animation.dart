import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PageFlipAnimation extends StatelessWidget {
  final String imagePath;
  final bool isLeftPage;

  const PageFlipAnimation({
    Key? key,
    required this.imagePath,
    required this.isLeftPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();

    return GestureDetector(
      onTap: () async {
        await audioPlayer.play(AssetSource('assets/audio/page_flip.mp3'));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        transform: Matrix4.rotationY(isLeftPage ? 0.0 : 3.14),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}