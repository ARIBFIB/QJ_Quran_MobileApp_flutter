import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:quran_qj_flutter_app/providers/quran_provider.dart';

class BookView extends StatefulWidget {
  const BookView({Key? key}) : super(key: key);


  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int currentPageIndex = 0;
  final int totalPages = 604;
  bool _isFlipping = false;
  bool _flipDirection = true; // true for next, false for previous

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_flipDirection && currentPageIndex < totalPages - 2) {
            currentPageIndex += 2;
          } else if (!_flipDirection && currentPageIndex > 0) {
            currentPageIndex -= 2;
          }
          _isFlipping = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }


  void _flipPage(bool isNext) {
    if (_isFlipping) return;

    bool canFlip = isNext
        ? currentPageIndex < totalPages - 2
        : currentPageIndex > 0;

    if (canFlip) {
      setState(() {
        _isFlipping = true;
        _flipDirection = isNext;
      });


      // 🔊 Only play sound if enabled in provider
      final provider = Provider.of<QuranProvider>(context, listen: false);
      if (provider.soundEnabled) {
      }

      _animationController.forward();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            // Swipe right (previous page)
            _flipPage(false);
          } else if (details.primaryVelocity! < -300) {
            // Swipe left (next page)
            _flipPage(true);
          }
        },
        onTap: () {
          // Tap on right side for next page, left side for previous
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = (context.findRenderObject() as RenderBox?)
              ?.globalToLocal(Offset.zero);
          
          if (tapPosition != null && tapPosition.dx > screenWidth / 2) {
            _flipPage(true);
          } else {
            _flipPage(false);
          }
        },
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            return _buildBookPages();
          },
        ),
      ),
    );
  }

  Widget _buildBookPages() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final pageWidth = screenWidth / 2;

        return Stack(
          children: [
            // Background pages (next set)
            if (_isFlipping && _flipDirection && currentPageIndex < totalPages - 4)
              _buildPagePair(currentPageIndex + 2, pageWidth, screenHeight),
            if (_isFlipping && !_flipDirection && currentPageIndex > 2)
              _buildPagePair(currentPageIndex - 2, pageWidth, screenHeight),
            
            // Current pages
            if (!_isFlipping || (_isFlipping && !_flipDirection))
              _buildPagePair(currentPageIndex, pageWidth, screenHeight),
            
            // Flipping page animation
            if (_isFlipping)
              _buildFlippingPage(pageWidth, screenHeight),
          ],
        );
      },
    );
  }

  Widget _buildPagePair(int pageIndex, double pageWidth, double screenHeight) {
    return Row(
      children: [
        // Left page
        Container(
          width: pageWidth,
          height: screenHeight,
          child: _buildPage(pageIndex),
        ),
        // Right page
        Container(
          width: pageWidth,
          height: screenHeight,
          child: _buildPage(pageIndex + 1),
        ),
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    if (pageIndex >= totalPages) return Container(color: Colors.white);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/quran/theme1/${pageIndex + 1}.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildFlippingPage(double pageWidth, double screenHeight) {
    final flipValue = _flipAnimation.value;
    final angle = _flipDirection 
        ? -math.pi * flipValue 
        : math.pi * flipValue;

    return Positioned(
      left: _flipDirection ? pageWidth : 0,
      child: Transform(
        alignment: _flipDirection ? Alignment.centerLeft : Alignment.centerRight,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: Container(
          width: pageWidth,
          height: screenHeight,
          child: _flipDirection 
              ? _buildPage(currentPageIndex + 1)
              : _buildPage(currentPageIndex),
        ),
      ),
    );
  }
}