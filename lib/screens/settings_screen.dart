import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/quran_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final quranProvider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle between light and dark theme'),
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
                  // const Divider(),
                  // ListTile(
                  //   title: const Text('Font Size'),
                  //   subtitle: Text('Current: ${_fontSize.toInt()}px'),
                  //   trailing: SizedBox(
                  //     width: 150,
                  //     child: Slider(
                  //       value: _fontSize,
                  //       min: 12.0,
                  //       max: 24.0,
                  //       divisions: 12,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _fontSize = value;
                  //         });
                  //       },
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quran Font/Theme Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quran Font Style',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Current Font Style'),
                    subtitle: Text(quranProvider.selectedTheme),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () => _showFontSelectionDialog(),
                  ),
                  const Divider(),
                  Text(
                    'Description: ${quranProvider.getThemeDescription(quranProvider.selectedTheme)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification Settings
          // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Notifications',
          //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         const SizedBox(height: 16),
          //         SwitchListTile(
          //           title: const Text('Enable Notifications'),
          //           subtitle: const Text('Receive reading reminders'),
          //           value: quranProvider.notificationsEnabled,
          //           onChanged: (value) {
          //             quranProvider.updateNotificationSettings(
          //               value,
          //               quranProvider.alarmTone,
          //               quranProvider.alarmTitle,
          //               quranProvider.alarmDescription,
          //             );
          //           },
          //           secondary: const Icon(Icons.notifications_rounded),
          //         ),
          //         if (quranProvider.notificationsEnabled) ...[
          //           const Divider(),
          //           ListTile(
          //             title: const Text('Alarm Tone'),
          //             subtitle: Text(quranProvider.alarmTone),
          //             trailing: DropdownButton<String>(
          //               value: quranProvider.alarmTone,
          //               items: const [
          //                 DropdownMenuItem(value: 'Default', child: Text('Default')),
          //                 DropdownMenuItem(value: 'Gentle', child: Text('Gentle')),
          //                 DropdownMenuItem(value: 'Peaceful', child: Text('Peaceful')),
          //               ],
          //               onChanged: (value) {
          //                 if (value != null) {
          //                   quranProvider.updateNotificationSettings(
          //                     quranProvider.notificationsEnabled,
          //                     value,
          //                     quranProvider.alarmTitle,
          //                     quranProvider.alarmDescription,
          //                   );
          //                 }
          //               },
          //             ),
          //           ),
          //           const Divider(),
          //           ListTile(
          //             title: const Text('Notification Title'),
          //             subtitle: Text(quranProvider.alarmTitle),
          //             trailing: const Icon(Icons.edit),
          //             onTap: () => _showEditNotificationDialog('title'),
          //           ),
          //           const Divider(),
          //           ListTile(
          //             title: const Text('Notification Description'),
          //             subtitle: Text(quranProvider.alarmDescription),
          //             trailing: const Icon(Icons.edit),
          //             onTap: () => _showEditNotificationDialog('description'),
          //           ),
          //         ],
          //       ],
          //     ),
          //   ),
          // ),
          
          const SizedBox(height: 16),
          
          // Reading Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(_selectedLanguage),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        // DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
                        // DropdownMenuItem(value: 'Urdu', child: Text('Urdu')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Play sound when turning pages'),
                    value: quranProvider.soundEnabled,
                    onChanged: (value) {
                      quranProvider.toggleSound(value);
                    },
                    secondary: const Icon(Icons.volume_up_rounded),
                  ),

                  // const Divider(),
                  // SwitchListTile(
                  //   title: const Text('Auto Bookmark'),
                  //   subtitle: const Text('Automatically bookmark last read page'),
                  //   value: _autoBookmark,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _autoBookmark = value;
                  //     });
                  //   },
                  //   secondary: const Icon(Icons.bookmark_add_rounded),
                  // ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.search_rounded),
                    title: const Text('Go to Page'),
                    subtitle: const Text('Navigate to specific page'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: _showGoToPageDialog,
                  ),
                  // const Divider(),
                  // ListTile(
                  //   leading: const Icon(Icons.list_rounded),
                  //   title: const Text('Go to Surah'),
                  //   subtitle: const Text('Navigate to specific Surah'),
                  //   trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  //   onTap: _showSurahDialog,
                  // ),
                  // const Divider(),
                  // ListTile(
                  //   leading: const Icon(Icons.numbers_rounded),
                  //   title: const Text('Go to Ruku'),
                  //   subtitle: const Text('Navigate to specific Ruku'),
                  //   trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  //   onTap: _showRukuDialog,
                  // ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.bookmark_rounded),
                    title: const Text('Manage Bookmarks'),
                    subtitle: Text('${quranProvider.bookmarks.length} bookmarks'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: _showBookmarksDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_rounded),
                    title: const Text('Clear All Bookmarks'),
                    subtitle: const Text('Remove all saved bookmarks'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: _showClearBookmarksDialog,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_rounded),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.code_rounded),
                    title: Text('Developer'),
                    subtitle: Text('Quran App Team'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSelectionDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Style'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: quranProvider.themeNames.map((themeName) {
              return RadioListTile<String>(
                title: Text(themeName),
                subtitle: Text(quranProvider.getThemeDescription(themeName)),
                value: themeName,
                groupValue: quranProvider.selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    quranProvider.changeTheme(value);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Font changed to $value'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
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

  void _showEditNotificationDialog(String type) {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();
    
    if (type == 'title') {
      controller.text = quranProvider.alarmTitle;
    } else {
      controller.text = quranProvider.alarmDescription;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Notification ${type == 'title' ? 'Title' : 'Description'}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: type == 'title' ? 'Title' : 'Description',
            border: const OutlineInputBorder(),
          ),
          maxLines: type == 'title' ? 1 : 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (type == 'title') {
                quranProvider.updateNotificationSettings(
                  quranProvider.notificationsEnabled,
                  quranProvider.alarmTone,
                  controller.text,
                  quranProvider.alarmDescription,
                );
              } else {
                quranProvider.updateNotificationSettings(
                  quranProvider.notificationsEnabled,
                  quranProvider.alarmTone,
                  quranProvider.alarmTitle,
                  controller.text,
                );
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification ${type} updated!')),
              );
            },
            child: const Text('Update'),
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
              if (pageNum != null) {
                quranProvider.navigateToPage(pageNum);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigated to page $pageNum')),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
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
          height: 300,
          child: ListView.builder(
            itemCount: quranProvider.surahs.length,
            itemBuilder: (context, index) {
              final surah = quranProvider.surahs[index];
              return RadioListTile<int>(
                title: Text(surah.name),
                subtitle: Text('Surah ${surah.number}'),
                value: surah.number,
                groupValue: quranProvider.currentSurah,
                onChanged: (value) {
                  if (value != null) {
                    quranProvider.navigateToSurah(value);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigated to ${surah.name}')),
                    );
                  }
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

  void _showRukuDialog() {
    final TextEditingController controller = TextEditingController();
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Ruku'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ruku Number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final rukuNum = int.tryParse(controller.text);
              if (rukuNum != null) {
                quranProvider.navigateToRuku(rukuNum);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigated to Ruku $rukuNum')),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showBookmarksDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: quranProvider.bookmarks.isEmpty
            ? const Center(child: Text('No bookmarks yet'))
            : ListView.builder(
                itemCount: quranProvider.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = quranProvider.bookmarks[index];
                  return ListTile(
                    title: Text(bookmark.title),
                    subtitle: Text(bookmark.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        quranProvider.removeBookmark(bookmark);
                        Navigator.pop(context);
                        _showBookmarksDialog(); // Refresh dialog
                      },
                    ),
                    onTap: () {
                      quranProvider.navigateToPage(bookmark.page);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearBookmarksDialog() {
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text('Are you sure you want to remove all bookmarks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              quranProvider.clearAllBookmarks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All bookmarks cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}