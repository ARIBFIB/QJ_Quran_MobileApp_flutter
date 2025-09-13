import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/quran_provider.dart';
import '../widgets/shimmer_loading.dart';
import 'quran_reader_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final quranProvider = Provider.of<QuranProvider>(context);

    if (_isLoading) {
      return const ShimmerLoading();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quran App',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeProvider.isDarkMode 
                  ? Icons.light_mode_rounded 
                  : Icons.dark_mode_rounded,
                key: ValueKey(themeProvider.isDarkMode),
              ),
            ),
          ),
          // Font selection button
          IconButton(
            onPressed: () => _showFontSelectionDialog(),
            icon: const Icon(Icons.font_download_rounded),
            tooltip: 'Change Font Style',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuranReaderScreen(
              startPage: quranProvider.currentPage,
            )),
          );
        },
        child: const Icon(Icons.menu_book_rounded),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final quranProvider = Provider.of<QuranProvider>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Quran App',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 500.ms),
                Text(
                  'Font: ${quranProvider.selectedTheme}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Continue Reading'),
            subtitle: Text('Page ${quranProvider.currentPage + 1}'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuranReaderScreen(
                  startPage: quranProvider.currentPage,
                )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.font_download_rounded),
            title: const Text('Font Style'),
            subtitle: Text(quranProvider.selectedTheme),
            onTap: () {
              Navigator.pop(context);
              _showFontSelectionDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_rounded),
            title: const Text('Bookmarks'),
            subtitle: Text('${quranProvider.bookmarks.length} saved'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode 
                ? Icons.dark_mode_rounded 
                : Icons.light_mode_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildSurahTab();
      case 2:
        return _buildBookmarksTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final quranProvider = Provider.of<QuranProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card with continue reading
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Reading',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Page ${quranProvider.currentPage + 1} • ${quranProvider.currentSurahModel.name}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Font: ${quranProvider.selectedTheme}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QuranReaderScreen(
                                startPage: quranProvider.currentPage,
                              )),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    child: Image.asset(
                      'assets/images/logo/logo.png', // Your logo path
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          
          const SizedBox(height: 20),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildQuickActionCard(
                icon: Icons.search_rounded,
                title: 'Go to Page',
                subtitle: 'Navigate directly',
                onTap: _showGoToPageDialog,
              ),
              _buildQuickActionCard(
                icon: Icons.list_rounded,
                title: 'All Surahs',
                subtitle: '${quranProvider.surahs.length} Surahs',
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              _buildQuickActionCard(
                icon: Icons.bookmark_rounded,
                title: 'Bookmarks',
                subtitle: '${quranProvider.bookmarks.length} saved',
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              _buildQuickActionCard(
                icon: Icons.font_download_rounded,
                title: 'Change Font',
                subtitle: quranProvider.selectedTheme,
                onTap: _showFontSelectionDialog,
              ),
            ],
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
          
          const SizedBox(height: 20),
          
          // Current Surah info
          Text(
            'Current Surah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  '${quranProvider.currentSurah}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(quranProvider.currentSurahModel.name),
              subtitle: Text('${quranProvider.currentSurahModel.arabicName} • ${quranProvider.currentSurahModel.verses} verses'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuranReaderScreen(
                    startPage: quranProvider.currentPage,
                  )),
                );
              },
            ),
          ).animate().fadeIn(duration: 1000.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSurahTab() {
    final quranProvider = Provider.of<QuranProvider>(context);
    
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Surah...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase().trim();
              });
            },
          ),
        ),
        
        // Surah list
        Expanded(
          child: Builder(
            builder: (context) {
              // 1. Filter surahs based on search query
              final filteredSurahs = quranProvider.surahs.where((surah) {
                final name = surah.name.toLowerCase();
                final arabicName = surah.arabicName.toLowerCase();
                final query = _searchQuery.toLowerCase();
                return query.isEmpty ||
                    name.contains(query) ||
                    arabicName.contains(query) ||
                    surah.number.toString().contains(query);
              }).toList();

              // 2. Build list with filteredSurahs
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = filteredSurahs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          '${surah.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        surah.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${surah.arabicName} • ${surah.verses} verses • Pages ${surah.startPage}-${surah.endPage}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        quranProvider.navigateToSurah(surah.number);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranReaderScreen(
                              startPage: quranProvider.currentPage,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(
                    duration: 1000.ms,
                    delay: Duration(milliseconds: index * 2),
                  )
                      .slideX(begin: 0.2);
                },
              );
            },
          ),
        ),

      ],
    );
  }

  Widget _buildBookmarksTab() {
    final quranProvider = Provider.of<QuranProvider>(context);
    
    if (quranProvider.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading and bookmark your favorite pages',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quranProvider.bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = quranProvider.bookmarks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(
              Icons.bookmark_rounded,
              color: Color(0xFF2E7D32),
            ),
            title: Text(bookmark.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookmark.description),
                if (bookmark.timerMinutes != null)
                  Text(
                    'Timer: ${bookmark.timerMinutes} minutes',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                // PopupMenuItem(
                //   value: 'edit',
                //   child: const Row(
                //     children: [
                //       Icon(Icons.edit),
                //       SizedBox(width: 8),
                //       Text('Edit'),
                //     ],
                //   ),
                // ),
                // PopupMenuItem(
                //   value: 'timer',
                //   child: const Row(
                //     children: [
                //       Icon(Icons.timer),
                //       SizedBox(width: 8),
                //       Text('Set Timer'),
                //     ],
                //   ),
                // ),
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditBookmarkDialog(bookmark);
                    break;
                  case 'timer':
                    _showSetTimerDialog(bookmark);
                    break;
                  case 'delete':
                    quranProvider.removeBookmark(bookmark);
                    break;
                }
              },
            ),
            onTap: () {
              quranProvider.navigateToPage(bookmark.page);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuranReaderScreen(
                  startPage: quranProvider.currentPage,
                )),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_rounded),
          label: 'Surahs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_rounded),
          label: 'Bookmarks',
        ),
      ],
    );
  }

  void _showFontSelectionDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.font_download_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Select Font Style'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: quranProvider.themeNames.map((themeName) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text(
                    themeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(quranProvider.getThemeDescription(themeName)),
                  value: themeName,
                  groupValue: quranProvider.selectedTheme,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      quranProvider.changeTheme(value);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Font changed to $value'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),
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

  void _showGoToPageDialog() {
    final TextEditingController controller = TextEditingController();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Page Number (1-${quranProvider.totalPages})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ],
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
                quranProvider.navigateToPage(pageNum);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuranReaderScreen(
                    startPage: quranProvider.currentPage,
                  )),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid page number (1-${quranProvider.totalPages})'),
                  ),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showEditBookmarkDialog(BookmarkModel bookmark) {
    final TextEditingController titleController = TextEditingController(text: bookmark.title);
    final TextEditingController descriptionController = TextEditingController(text: bookmark.description);
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              quranProvider.updateBookmark(
                bookmark,
                titleController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark updated!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSetTimerDialog(BookmarkModel bookmark) {
    final TextEditingController minutesController = TextEditingController();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reading Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                border: OutlineInputBorder(),
                suffixText: 'min',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set a timer to remind you to continue reading from this bookmark.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text);
              if (minutes != null && minutes > 0) {
                quranProvider.setBookmarkTimer(bookmark, minutes);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Timer set for $minutes minutes')),
                );
              }
            },
            child: const Text('Set Timer'),
          ),
        ],
      ),
    );
  }
}