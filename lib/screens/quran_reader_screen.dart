import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran_qj_flutter_app/widgets/book_view.dart';
import '../providers/quran_provider.dart';
import '../providers/theme_provider.dart';

class QuranReaderScreen extends StatefulWidget {
  final int startPage;

  const QuranReaderScreen({Key? key, required this.startPage}) : super(key: key);

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _isUIVisible = true;
  bool _isStretchView = false;


  @override
  void initState() {
    super.initState();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    if (quranProvider.currentPage != widget.startPage) {
      quranProvider.navigateToPage(widget.startPage);
    }


    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Set initial page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      final initialPage = quranProvider.currentPage ~/ 2;
      if (initialPage < (quranProvider.totalPages / 2).ceil()) {
        _pageController.jumpToPage(initialPage);
      }
    });
  }

  @override
  void dispose() {
    // Reset orientation when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isUIVisible = !_isUIVisible;
          });
        },
        child: Stack(
          children: [
            // Main page view
            quranProvider.isZoomEnabled
                ? _buildZoomedView(quranProvider)
                : _buildNormalView(quranProvider),

            // Top controls
            if (_isUIVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Page ${quranProvider.currentPage + 1} of ${quranProvider.totalPages}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                quranProvider.currentSurahModel.name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showOptionsMenu(),
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom controls
            if (_isUIVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: quranProvider.currentPage > 0
                              ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                              : null,
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white, size: 32),
                        ),
                        IconButton(
                          onPressed: () => _showGoToPageDialog(),
                          icon: const Icon(Icons.search, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => _showGoToParaDialog(),
                          icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            _showBookmarkDialog();
                          },
                          icon:
                          const Icon(Icons.bookmark_add, color: Colors.white),
                        ),
                        IconButton(
                          onPressed:
                          quranProvider.currentPage < quranProvider.totalPages - 1
                              ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                              : null,
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalView(QuranProvider quranProvider) {
    return PageView.builder(
      controller: _pageController,
      reverse: true, // Right to left scrolling
      itemCount: (quranProvider.quranPages.length / 2).ceil(),
      onPageChanged: (index) {
        quranProvider.setCurrentPage(index * 2);
        quranProvider.playPageFlipSound();
      },
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        return Row(
          children: [
            if (secondIndex < quranProvider.quranPages.length)
              Expanded(
                child: _buildPage(quranProvider.quranPages[secondIndex], isLeftPage: true),
              ),
            Expanded(
              child: _buildPage(quranProvider.quranPages[firstIndex], isLeftPage: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZoomedView(QuranProvider quranProvider) {
    return PageView.builder(
      controller: _pageController,
      reverse: true, // Right-to-left navigation
      itemCount: (quranProvider.quranPages.length / 2).ceil(),
      onPageChanged: (index) {
        quranProvider.setCurrentPage(index * 2);
      },
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        return SingleChildScrollView(
          controller: _scrollController, // shared scroll → both pages move together
          scrollDirection: Axis.vertical,
          child: Row(
            children: [
              if (secondIndex < quranProvider.quranPages.length)
                Expanded(
                  child: _buildZoomedPage(quranProvider.quranPages[secondIndex]),
                ),
              Expanded(
                child: _buildZoomedPage(quranProvider.quranPages[firstIndex]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZoomedPage(String imagePath) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 1.0,
      maxScale: 3.0,
      child: Image.asset(
        imagePath,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }


  // Widget _buildPage(String imagePath) {
  //   return Container(
  //     margin: const EdgeInsets.all(0), // remove margin to connect seamlessly
  //     child: Image.asset(
  //       imagePath,
  //       fit: BoxFit.contain,
  //       // fit: BoxFit.fitHeight, // Changed for better zoom experience
  //       alignment: Alignment.center,
  //       errorBuilder: (context, error, stackTrace) {
  //         return Container(
  //           color: Colors.grey.shade200,
  //           child: const Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
  //                 SizedBox(height: 8),
  //                 Text('Image not found', style: TextStyle(color: Colors.grey)),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget _buildPage(String imagePath, {required bool isLeftPage}) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Image.asset(
        imagePath,
        fit: _isStretchView ? BoxFit.fill : BoxFit.contain,
        alignment: isLeftPage ? Alignment.centerRight : Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Image not found', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildZoomedPage(String imagePath) {
  //   return Container(
  //     margin: const EdgeInsets.all(4),
  //     child: Image.asset(
  //       imagePath,
  //       fit: BoxFit.fitWidth, // Changed for better zoom experience
  //       alignment: Alignment.topCenter,
  //       errorBuilder: (context, error, stackTrace) {
  //         return Container(
  //           color: Colors.grey.shade200,
  //           child: const Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
  //                 SizedBox(height: 8),
  //                 Text('Image not found', style: TextStyle(color: Colors.grey)),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  void _showOptionsMenu() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // <-- allows more height
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7, // 60% of screen height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar (for drag)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              "Options",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),

            // Scrollable list of options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        quranProvider.isZoomEnabled ? Icons.zoom_out : Icons.zoom_in,
                        color: Colors.blueGrey,
                      ),
                      title: Text(quranProvider.isZoomEnabled ? 'Disable Zoom' : 'Enable Zoom',
                        style: const TextStyle(color: Colors.black), // ✅ Title text will be black
                      ),
                      subtitle: Text(quranProvider.isZoomEnabled
                          ? 'Switch to normal view'
                          : 'Enable scrollable zoom view' ,
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        final currentPageIndex = quranProvider.currentPage ~/ 2;
                        quranProvider.toggleZoom();
                        if (!quranProvider.isZoomEnabled) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _pageController.jumpToPage(currentPageIndex);
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_size_select_large, color: Colors.blueGrey),
                      title: Text(
                        'Change View',
                        style: const TextStyle(color: Colors.black), // ✅ Title text will be black
                      ),
                      subtitle: Text(
                        _isStretchView
                            ? 'Currently: Stretch (Fill)'
                            : 'Currently: Default (Contain)',
                        style: const TextStyle(color: Colors.black54), // optional: make subtitle darker gray
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showViewOptionsDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.search, color: Colors.blueGrey),
                      title: const Text('Go to Page',
                        style: const TextStyle(color: Colors.black), // ✅ Title text will be black
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showGoToPageDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.list, color: Colors.blueGrey),
                      title: const Text('Go to Surah',
                        style: const TextStyle(color: Colors.black), // ✅ Title text will be black
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showSurahDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.blueGrey),
                      title: const Text('Bookmark this page',
                        style: const TextStyle(color: Colors.black), // ✅ Title text will be black
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showBookmarkDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showViewOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Default (Fill)'),
              value: true,
              groupValue: _isStretchView,
              onChanged: (value) {
                setState(() {
                  _isStretchView = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<bool>(
              title: const Text('Fit (Contain)'),
              value: false,
              groupValue: _isStretchView,
              onChanged: (value) {
                setState(() {
                  _isStretchView = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarkDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    titleController.text = "Page ${quranProvider.currentPage + 1}";
    descriptionController.text = "Bookmark in ${quranProvider.selectedTheme}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: SingleChildScrollView( // ✅ Prevent overflow when keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              quranProvider.addBookmark(
                quranProvider.currentPage,
                customTitle: titleController.text,
                customDescription: descriptionController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark added!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


  void _showGoToPageDialog() {
    final TextEditingController controller = TextEditingController();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Page Number (1-${quranProvider.totalPages})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNum = int.tryParse(controller.text);
              if (pageNum != null && pageNum > 0 && pageNum <= quranProvider.totalPages) {
                final pageIndex = (pageNum - 1) ~/ 2;
                _pageController.animateToPage(
                  pageIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showGoToParaDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    // Example para names - you can customize with correct names if you have them
    final List<Map<String, String>> paraNames = [
      {"english": "Alif Lam Meem", "arabic": "الم"},
      {"english": "Sayaqool", "arabic": "سَيَقُولُ"},
      {"english": "Tilkal Rusul", "arabic": "تِلْكَ الرُّسُلُ"},
      {"english": "Lan TanaLoo", "arabic": "لَنْ تَنَالُوا"},
      {"english": "Wal Mohsanat", "arabic": "وَالْمُحْصَنَاتُ"},
      {"english": "Ya Ayyuha", "arabic": "يَا أَيُّهَا"},
      {"english": "Wa Iza Samiu", "arabic": "وَإِذَا سَمِعُوا"},
      {"english": "Qad Aflaha", "arabic": "قَدْ أَفْلَحَ"},
      {"english": "Qad Sami Allah", "arabic": "قَدْ سَمِعَ اللهُ"},
      {"english": "Wa A'lamu", "arabic": "وَأَعْلَمُوا"},
      {"english": "Yatazeroon", "arabic": "يَتَذَرُونَ"},
      {"english": "Wa Mamin Da’abat", "arabic": "وَمَا مِن دَابَّةٍ"},
      {"english": "Wa Ma Ubrioo", "arabic": "وَمَا أُبَرِّئُ"},
      {"english": "Rubama", "arabic": "رُّبَمَا"},
      {"english": "Subhanallazi", "arabic": "سُبْحَانَ الَّذِي"},
      {"english": "Qal Alam", "arabic": "قَالَ أَلَمْ"},
      {"english": "Iqtarabat", "arabic": "اقْتَرَبَتْ"},
      {"english": "Qadd Aflaha (Al-Muminun)", "arabic": "قَدْ أَفْلَحَ"},
      {"english": "Wa Qala Allazina", "arabic": "وَقَالَ الَّذِينَ"},
      {"english": "A’man Khalaq", "arabic": "أَمَّنْ خَلَقَ"},
      {"english": "Uttil Ma", "arabic": "اتَّلَىٰ مَا"},
      {"english": "Wa Manyaqnut", "arabic": "وَمَنْ يَقْنُتْ"},
      {"english": "Wa Mali", "arabic": "وَمَا لِي"},
      {"english": "Faman Azlam", "arabic": "فَمَنْ أَظْلَمُ"},
      {"english": "Ha Meem Sajdah", "arabic": "حم"},
      {"english": "Ha Meem Ad Dukhan", "arabic": "حم"},
      {"english": "Qala Fama Khatb", "arabic": "قَالَ فَمَا خَطْبُ"},
      {"english": "Qadd Sami Allah (Mujadila)", "arabic": "قَدْ سَمِعَ اللهُ"},
      {"english": "Tabarak", "arabic": "تَبَارَكَ"},
      {"english": "Amma Yatasa'aloon", "arabic": "عَمَّ يَتَسَاءَلُونَ"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar for bottom sheet
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Select Para",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: paraNames.length,
                  itemBuilder: (context, index) {
                    final para = paraNames[index];
                    return GestureDetector(
                      // onTap: () {
                      //   final targetPage = quranProvider.paraStartPages[index + 1] ?? 1;
                      //   final pageIndex = (targetPage - 1) ~/ 2; // if each page shows 2 pages side by side
                      //   _pageController.animateToPage(
                      //     pageIndex,
                      //     duration: const Duration(milliseconds: 400),
                      //     curve: Curves.easeInOut,
                      //   );
                      //   quranProvider.setCurrentPage(targetPage - 1);
                      //   Navigator.pop(context);
                      // },
                      onTap: () {
                        final targetPage = quranProvider.paraStartPages[index + 1] ?? 1;
                        final pageIndex = (targetPage - 1) ~/ 2;
                        _pageController.animateToPage(
                          pageIndex,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                        quranProvider.setCurrentPage(targetPage - 1);
                        Navigator.pop(context);
                      },

                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade100, Colors.grey.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // English name + number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Para ${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  para["english"]!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            // Arabic name
                            Text(
                              para["arabic"]!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: "Amiri", // nice Arabic font
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  void _showSurahDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Surah'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: quranProvider.surahs.length,
            itemBuilder: (context, index) {
              final surah = quranProvider.surahs[index];
              return ListTile(
                title: Text(surah.name),
                subtitle: Text('${surah.arabicName} • ${surah.verses} verses • Pages ${surah.startPage}-${surah.endPage}'),
                onTap: () {
                  quranProvider.navigateToSurah(surah.number);
                  final pageIndex = (surah.startPage - 1) ~/ 2;
                  _pageController.animateToPage(
                    pageIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}