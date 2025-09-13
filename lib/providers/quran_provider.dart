import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentPage = 0;
  int _currentSurah = 1;
  int _currentRuku = 1;
  bool _isLoading = false;
  List<BookmarkModel> _bookmarks = [];
  String _selectedTheme = 'Indo-Pak Font';
  bool _isZoomEnabled = false;
  bool _notificationsEnabled = true;
  String _alarmTone = 'Default';
  String _alarmTitle = 'Quran Reading Reminder';
  String _alarmDescription = 'Time to continue your Quran reading';
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;


  // Available themes/fonts
  final Map<String, QuranTheme> _themes = {
    'Indo-Pak Font': QuranTheme(
      name: 'Indo-Pak Font',
      description: 'Traditional Pakistani print style',
      basePath: 'assets/images/quran/theme3/',
      filePrefix: 'QuranMajeed-15Lines-PakistaniPrint_',
      fileExtension: '.png',
      // pageNumbers: [1,2,461, 476, 477, 481, 502, 587],
      pageNumbers: List.generate(610, (index) => index + 1),
    ),
    // 'Font 2': QuranTheme(
    //   name: 'Font 2',
    //   description: 'Modern Arabic font style',
    //   basePath: 'assets/images/quran/theme1/',
    //   filePrefix: 'QuranMajeed-15Lines-PakistaniPrint_',
    //   fileExtension: '.png',
    //   pageNumbers: [1,2,461, 476, 477, 481, 502, 587],
    //   // pageNumbers: List.generate(604, (index) => index + 1),
    // ),
    // 'Font 3': QuranTheme(
    //   name: 'Font 3',
    //   description: 'Classic Arabic font style',
    //   basePath: 'assets/images/quran/theme2/',
    //   filePrefix: '',
    //   fileExtension: '.png',
    //   pageNumbers: List.generate(604, (index) => index + 1),
    // ),
  };

  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }


  final List<SurahModel> _surahs = [
    SurahModel(number: 1, name: "Al-Fatiha", arabicName: "الفاتحة", startPage: 1, endPage: 1, verses: 7),
    SurahModel(number: 2, name: "Al-Baqarah", arabicName: "البقرة", startPage: 2, endPage: 49, verses: 286),
    SurahModel(number: 3, name: "Aal-E-Imran", arabicName: "آل عمران", startPage: 50, endPage: 76, verses: 200),
    SurahModel(number: 4, name: "An-Nisa", arabicName: "النساء", startPage: 77, endPage: 106, verses: 176),
    SurahModel(number: 5, name: "Al-Maidah", arabicName: "المائدة", startPage: 106, endPage: 127, verses: 120),
    SurahModel(number: 6, name: "Al-An'am", arabicName: "الأنعام", startPage: 128, endPage: 151, verses: 165),
    SurahModel(number: 7, name: "Al-A'raf", arabicName: "الأعراف", startPage: 151, endPage: 176, verses: 206),
    SurahModel(number: 8, name: "Al-Anfal", arabicName: "الأنفال", startPage: 177, endPage: 187, verses: 75),
    SurahModel(number: 9, name: "At-Tawbah", arabicName: "التوبة", startPage: 187, endPage: 207, verses: 129),
    SurahModel(number: 10, name: "Yunus", arabicName: "يونس", startPage: 208, endPage: 221, verses: 109),
    SurahModel(number: 11, name: "Hud", arabicName: "هود", startPage: 221, endPage: 235, verses: 123),
    SurahModel(number: 12, name: "Yusuf", arabicName: "يوسف", startPage: 235, endPage: 248, verses: 111),
    SurahModel(number: 13, name: "Ar-Ra'd", arabicName: "الرعد", startPage: 249, endPage: 255, verses: 43),
    SurahModel(number: 14, name: "Ibrahim", arabicName: "إبراهيم", startPage: 255, endPage: 261, verses: 52),
    SurahModel(number: 15, name: "Al-Hijr", arabicName: "الحجر", startPage: 262, endPage: 267, verses: 99),
    SurahModel(number: 16, name: "An-Nahl", arabicName: "النحل", startPage: 267, endPage: 281, verses: 128),
    SurahModel(number: 17, name: "Al-Isra", arabicName: "الإسراء", startPage: 282, endPage: 293, verses: 111),
    SurahModel(number: 18, name: "Al-Kahf", arabicName: "الكهف", startPage: 293, endPage: 304, verses: 110),
    SurahModel(number: 19, name: "Maryam", arabicName: "مريم", startPage: 305, endPage: 312, verses: 98),
    SurahModel(number: 20, name: "Taha", arabicName: "طه", startPage: 312, endPage: 322, verses: 135),
    SurahModel(number: 21, name: "Al-Anbiya", arabicName: "الأنبياء", startPage: 322, endPage: 332, verses: 112),
    SurahModel(number: 22, name: "Al-Hajj", arabicName: "الحج", startPage: 332, endPage: 341, verses: 78),
    SurahModel(number: 23, name: "Al-Mu'minun", arabicName: "المؤمنون", startPage: 342, endPage: 350, verses: 118),
    SurahModel(number: 24, name: "An-Nur", arabicName: "النور", startPage: 350, endPage: 359, verses: 64),
    SurahModel(number: 25, name: "Al-Furqan", arabicName: "الفرقان", startPage: 359, endPage: 366, verses: 77),
    SurahModel(number: 26, name: "Ash-Shu'ara", arabicName: "الشعراء", startPage: 367, endPage: 376, verses: 227),
    SurahModel(number: 27, name: "An-Naml", arabicName: "النمل", startPage: 377, endPage: 385, verses: 93),
    SurahModel(number: 28, name: "Al-Qasas", arabicName: "القصص", startPage: 385, endPage: 396, verses: 88),
    SurahModel(number: 29, name: "Al-Ankabut", arabicName: "العنكبوت", startPage: 396, endPage: 404, verses: 69),
    SurahModel(number: 30, name: "Ar-Rum", arabicName: "الروم", startPage: 404, endPage: 410, verses: 60),
    SurahModel(number: 31, name: "Luqman", arabicName: "لقمان", startPage: 411, endPage: 414, verses: 34),
    SurahModel(number: 32, name: "As-Sajda", arabicName: "السجدة", startPage: 415, endPage: 417, verses: 30),
    SurahModel(number: 33, name: "Al-Ahzab", arabicName: "الأحزاب", startPage: 418, endPage: 427, verses: 73),
    SurahModel(number: 34, name: "Saba", arabicName: "سبأ", startPage: 428, endPage: 434, verses: 54),
    SurahModel(number: 35, name: "Fatir", arabicName: "فاطر", startPage: 434, endPage: 440, verses: 45),
    SurahModel(number: 36, name: "Ya-Sin", arabicName: "يس", startPage: 440, endPage: 445, verses: 83),
    SurahModel(number: 37, name: "As-Saffat", arabicName: "الصافات", startPage: 446, endPage: 452, verses: 182),
    SurahModel(number: 38, name: "Sad", arabicName: "ص", startPage: 453, endPage: 458, verses: 88),
    SurahModel(number: 39, name: "Az-Zumar", arabicName: "الزمر", startPage: 458, endPage: 467, verses: 75),
    SurahModel(number: 40, name: "Ghafir", arabicName: "غافر", startPage: 467, endPage: 476, verses: 85),
    SurahModel(number: 41, name: "Fussilat", arabicName: "فصلت", startPage: 477, endPage: 482, verses: 54),
    SurahModel(number: 42, name: "Ash-Shura", arabicName: "الشورى", startPage: 483, endPage: 489, verses: 53),
    SurahModel(number: 43, name: "Az-Zukhruf", arabicName: "الزخرف", startPage: 489, endPage: 495, verses: 89),
    SurahModel(number: 44, name: "Ad-Dukhan", arabicName: "الدخان", startPage: 496, endPage: 498, verses: 59),
    SurahModel(number: 45, name: "Al-Jathiya", arabicName: "الجاثية", startPage: 499, endPage: 502, verses: 37),
    SurahModel(number: 46, name: "Al-Ahqaf", arabicName: "الأحقاف", startPage: 502, endPage: 506, verses: 35),
    SurahModel(number: 47, name: "Muhammad", arabicName: "محمد", startPage: 507, endPage: 510, verses: 38),
    SurahModel(number: 48, name: "Al-Fath", arabicName: "الفتح", startPage: 511, endPage: 515, verses: 29),
    SurahModel(number: 49, name: "Al-Hujurat", arabicName: "الحجرات", startPage: 515, endPage: 517, verses: 18),
    SurahModel(number: 50, name: "Qaf", arabicName: "ق", startPage: 518, endPage: 520, verses: 45),
    SurahModel(number: 51, name: "Adh-Dhariyat", arabicName: "الذاريات", startPage: 520, endPage: 523, verses: 60),
    SurahModel(number: 52, name: "At-Tur", arabicName: "الطور", startPage: 523, endPage: 525, verses: 49),
    SurahModel(number: 53, name: "An-Najm", arabicName: "النجم", startPage: 526, endPage: 528, verses: 62),
    SurahModel(number: 54, name: "Al-Qamar", arabicName: "القمر", startPage: 528, endPage: 531, verses: 55),
    SurahModel(number: 55, name: "Ar-Rahman", arabicName: "الرحمن", startPage: 531, endPage: 534, verses: 78),
    SurahModel(number: 56, name: "Al-Waqia", arabicName: "الواقعة", startPage: 534, endPage: 537, verses: 96),
    SurahModel(number: 57, name: "Al-Hadid", arabicName: "الحديد", startPage: 537, endPage: 541, verses: 29),
    SurahModel(number: 58, name: "Al-Mujadila", arabicName: "المجادلة", startPage: 542, endPage: 545, verses: 22),
    SurahModel(number: 59, name: "Al-Hashr", arabicName: "الحشر", startPage: 545, endPage: 548, verses: 24),
    SurahModel(number: 60, name: "Al-Mumtahina", arabicName: "الممتحنة", startPage: 549, endPage: 551, verses: 13),
    SurahModel(number: 61, name: "As-Saff", arabicName: "الصف", startPage: 551, endPage: 552, verses: 14),
    SurahModel(number: 62, name: "Al-Jumua", arabicName: "الجمعة", startPage: 553, endPage: 554, verses: 11),
    SurahModel(number: 63, name: "Al-Munafiqun", arabicName: "المنافقون", startPage: 554, endPage: 555, verses: 11),
    SurahModel(number: 64, name: "At-Taghabun", arabicName: "التغابن", startPage: 556, endPage: 557, verses: 18),
    SurahModel(number: 65, name: "At-Talaq", arabicName: "الطلاق", startPage: 558, endPage: 559, verses: 12),
    SurahModel(number: 66, name: "At-Tahrim", arabicName: "التحريم", startPage: 560, endPage: 561, verses: 12),
    SurahModel(number: 67, name: "Al-Mulk", arabicName: "الملك", startPage: 562, endPage: 564, verses: 30),
    SurahModel(number: 68, name: "Al-Qalam", arabicName: "القلم", startPage: 564, endPage: 567, verses: 52),
    SurahModel(number: 69, name: "Al-Haaqqa", arabicName: "الحاقة", startPage: 567, endPage: 569, verses: 52),
    SurahModel(number: 70, name: "Al-Maarij", arabicName: "المعارج", startPage: 569, endPage: 571, verses: 44),
    SurahModel(number: 71, name: "Nuh", arabicName: "نوح", startPage: 571, endPage: 573, verses: 28),
    SurahModel(number: 72, name: "Al-Jinn", arabicName: "الجن", startPage: 573, endPage: 576, verses: 28),
    SurahModel(number: 73, name: "Al-Muzzammil", arabicName: "المزمل", startPage: 574, endPage: 577, verses: 20),
    SurahModel(number: 74, name: "Al-Muddathir", arabicName: "المدثر", startPage: 578, endPage: 580, verses: 56),
    SurahModel(number: 75, name: "Al-Qiyama", arabicName: "القيامة", startPage: 580, endPage: 581, verses: 40),
    SurahModel(number: 76, name: "Al-Insan", arabicName: "الإنسان", startPage: 582, endPage: 584, verses: 31),
    SurahModel(number: 77, name: "Al-Mursalat", arabicName: "المرسلات", startPage: 584, endPage: 585, verses: 50),
    SurahModel(number: 78, name: "An-Naba", arabicName: "النبأ", startPage: 586, endPage: 587, verses: 40),
    SurahModel(number: 79, name: "An-Nazi'at", arabicName: "النازعات", startPage: 587, endPage: 589, verses: 46),
    SurahModel(number: 80, name: "Abasa", arabicName: "عبس", startPage: 589, endPage: 590, verses: 42),
    SurahModel(number: 81, name: "At-Takwir", arabicName: "التكوير", startPage: 590, endPage: 591, verses: 29),
    SurahModel(number: 82, name: "Al-Infitar", arabicName: "الإنفطار", startPage: 591, endPage: 592, verses: 19),
    SurahModel(number: 83, name: "Al-Mutaffifin", arabicName: "المطففين", startPage: 592, endPage: 594, verses: 36),
    SurahModel(number: 84, name: "Al-Inshiqaq", arabicName: "الإنشقاق", startPage: 594, endPage: 595, verses: 25),
    SurahModel(number: 85, name: "Al-Buruj", arabicName: "البروج", startPage: 595, endPage: 596, verses: 22),
    SurahModel(number: 86, name: "At-Tariq", arabicName: "الطارق", startPage: 596, endPage: 596, verses: 17),
    SurahModel(number: 87, name: "Al-Ala", arabicName: "الأعلى", startPage: 597, endPage: 597, verses: 19),
    SurahModel(number: 88, name: "Al-Ghashiya", arabicName: "الغاشية", startPage: 597, endPage: 598, verses: 26),
    SurahModel(number: 89, name: "Al-Fajr", arabicName: "الفجر", startPage: 598, endPage: 599, verses: 30),
    SurahModel(number: 90, name: "Al-Balad", arabicName: "البلد", startPage: 599, endPage: 599, verses: 20),
    SurahModel(number: 91, name: "Ash-Shams", arabicName: "الشمس", startPage: 600, endPage: 601, verses: 15),
    SurahModel(number: 92, name: "Al-Lail", arabicName: "الليل", startPage: 601, endPage: 602, verses: 21),
    SurahModel(number: 93, name: "Ad-Duhaa", arabicName: "الضحى", startPage: 602, endPage: 602, verses: 11),
    SurahModel(number: 94, name: "Ash-Sharh", arabicName: "الشرح", startPage: 602, endPage: 602, verses: 8),
    SurahModel(number: 95, name: "At-Tin", arabicName: "التين", startPage: 603, endPage: 603, verses: 8),
    SurahModel(number: 96, name: "Al-Alaq", arabicName: "العلق", startPage: 603, endPage: 604, verses: 19),
    SurahModel(number: 97, name: "Al-Qadr", arabicName: "القدر", startPage: 603, endPage: 603, verses: 5),
    SurahModel(number: 98, name: "Al-Bayyina", arabicName: "البينة", startPage: 603, endPage: 604, verses: 8),
    SurahModel(number: 99, name: "Az-Zalzala", arabicName: "الزلزلة", startPage: 605, endPage: 605, verses: 8),
    SurahModel(number: 100, name: "Al-Adiyat", arabicName: "العاديات", startPage: 605, endPage: 605, verses: 11),
    SurahModel(number: 101, name: "Al-Qaria", arabicName: "القارعة", startPage: 605, endPage: 605, verses: 11),
    SurahModel(number: 102, name: "At-Takathur", arabicName: "التكاثر", startPage: 605, endPage: 605, verses: 8),
    SurahModel(number: 103, name: "Al-Asr", arabicName: "العصر", startPage: 607, endPage: 607, verses: 3),
    SurahModel(number: 104, name: "Al-Humaza", arabicName: "الهمزة", startPage: 607, endPage: 607, verses: 9),
    SurahModel(number: 105, name: "Al-Fil", arabicName: "الفيل", startPage: 607, endPage: 607, verses: 5),
    SurahModel(number: 106, name: "Quraish", arabicName: "قريش", startPage: 607, endPage: 607, verses: 4),
    SurahModel(number: 107, name: "Al-Ma'un", arabicName: "الماعون", startPage: 607, endPage: 607, verses: 7),
    SurahModel(number: 108, name: "Al-Kawthar", arabicName: "الكوثر", startPage: 607, endPage: 607, verses: 3),
    SurahModel(number: 109, name: "Al-Kafiroon", arabicName: "الكافرون", startPage: 608, endPage: 608, verses: 6),
    SurahModel(number: 110, name: "An-Nasr", arabicName: "النصر", startPage: 609, endPage: 609, verses: 3),
    SurahModel(number: 111, name: "Al-Masad", arabicName: "المسد", startPage: 609, endPage: 609, verses: 5),
    SurahModel(number: 112, name: "Al-Ikhlas", arabicName: "الإخلاص", startPage: 609, endPage: 609, verses: 4),
    SurahModel(number: 113, name: "Al-Falaq", arabicName: "الفلق", startPage: 609, endPage: 609, verses: 5),
    SurahModel(number: 114, name: "An-Nas", arabicName: "الناس", startPage: 609, endPage: 609, verses: 6),
  ];

  final Map<int, int> paraStartPages = {
    1: 1,
    2: 22,
    3: 42,
    4: 62,
    5: 82,
    6: 102,
    7: 122,
    8: 142,
    9: 162,
    10: 182,
    11: 202,
    12: 222,
    13: 242,
    14: 262,
    15: 282,
    16: 302,
    17: 322,
    18: 342,
    19: 362,
    20: 382,
    21: 402,
    22: 422,
    23: 442,
    24: 462,
    25: 482,
    26: 502,
    27: 522,
    28: 542,
    29: 562,
    30: 586,
  };


  QuranProvider() {
    _loadPreferences();
    _loadSoundPreference();
  }

  // int navigateToPara(int paraNumber) {
  //   return paraStartPages[paraNumber] ?? 1;
  // }

  void navigateToPara(int paraNumber) {
    if (paraNumber < 1 || paraNumber > paraStartPages.length) return;
    int page = paraStartPages[paraNumber] ?? 1; // fetch start page from map
    setCurrentPage(page - 1); // this updates provider state
    notifyListeners();
  }




  // Load the saved sound setting
  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true; // default ON
    notifyListeners();
  }

  // Getters
  int get currentPage => _currentPage;
  int get currentSurah => _currentSurah;
  int get currentRuku => _currentRuku;
  bool get isLoading => _isLoading;
  List<SurahModel> get surahs => _surahs;
  List<String> get surahNames => _surahs.map((s) => s.name).toList();
  List<BookmarkModel> get bookmarks => _bookmarks;
  String get selectedTheme => _selectedTheme;
  Map<String, QuranTheme> get themes => _themes;
  bool get isZoomEnabled => _isZoomEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get alarmTone => _alarmTone;
  String get alarmTitle => _alarmTitle;
  String get alarmDescription => _alarmDescription;

  // Get current theme pages
  List<String> get quranPages {
    final theme = _themes[_selectedTheme]!;
    return theme.pageNumbers.map((pageNum) {
      return '${theme.basePath}${theme.filePrefix}${pageNum.toString().padLeft(4, '0')}${theme.fileExtension}';
    }).toList();
  }
  
  int get totalPages => quranPages.length;

  // Load preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPage = prefs.getInt('currentPage') ?? 0;
    _currentSurah = prefs.getInt('currentSurah') ?? 1;
    _selectedTheme = prefs.getString('selectedTheme') ?? 'Indo-Pak Font';
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _alarmTone = prefs.getString('alarmTone') ?? 'Default';
    _alarmTitle = prefs.getString('alarmTitle') ?? 'Quran Reading Reminder';
    _alarmDescription = prefs.getString('alarmDescription') ?? 'Time to continue your Quran reading';
    
    // Load bookmarks
    final bookmarkStrings = prefs.getStringList('bookmarks') ?? [];
    _bookmarks = bookmarkStrings.map((str) => BookmarkModel.fromJson(str)).toList();
    
    notifyListeners();
  }

  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', _currentPage);
    await prefs.setInt('currentSurah', _currentSurah);
    await prefs.setString('selectedTheme', _selectedTheme);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('alarmTone', _alarmTone);
    await prefs.setString('alarmTitle', _alarmTitle);
    await prefs.setString('alarmDescription', _alarmDescription);
    
    // Save bookmarks
    final bookmarkStrings = _bookmarks.map((b) => b.toJson()).toList();
    await prefs.setStringList('bookmarks', bookmarkStrings);
  }

/// Add this private helper
  void _updateSurahForPageIndex(int pageIndex) {
    // pageIndex is zero-based (0 => page 1)
    final pageNumber = pageIndex + 1;

    // Find which surah contains this page
    final found = _surahs.indexWhere(
          (s) => pageNumber >= s.startPage && pageNumber <= s.endPage,
    );

    if (found != -1) {
      _currentSurah = _surahs[found].number; // update current surah
    } else {
      // If page doesn't belong to any surah (edge case)
      // we can keep the old value or fallback to first surah
      // _currentSurah = 1;
    }
  }


  // Toggle zoom
  void toggleZoom() {
    _isZoomEnabled = !_isZoomEnabled;
    notifyListeners();
  }

  // Change theme/font
  void changeTheme(String themeName) {
    if (_themes.containsKey(themeName)) {
      _selectedTheme = themeName;
      _savePreferences();
      notifyListeners();
    }
  }

  // Get available theme names
  List<String> get themeNames => _themes.keys.toList();

  // Get theme description
  String getThemeDescription(String themeName) {
    return _themes[themeName]?.description ?? '';
  }

  // Set current page
  // void setCurrentPage(int page) {
  //   if (page >= 0 && page < quranPages.length) {
  //     _currentPage = page;
  //     _savePreferences();
  //     notifyListeners();
  //   }
  // }

  void setCurrentPage(int page) {
    if (page >= 0 && page < quranPages.length) {
      _currentPage = page;
      _updateSurahForPageIndex(page);
      _savePreferences();
      notifyListeners();
    }
  }


  // Navigate to specific page
  // void navigateToPage(int pageNumber) {
  //   if (pageNumber > 0 && pageNumber <= quranPages.length) {
  //     _currentPage = pageNumber - 1;
  //     _savePreferences();
  //     notifyListeners();
  //   }
  // }
  void navigateToPage(int pageNumberOrIndex) {
    int pageIndex;

    // If user gave 1-based number (like 1..604)
    if (pageNumberOrIndex > 0 && pageNumberOrIndex <= quranPages.length) {
      pageIndex = pageNumberOrIndex - 1;
    }
    // If user already gave a zero-based index (0..603)
    else if (pageNumberOrIndex >= 0 && pageNumberOrIndex < quranPages.length) {
      pageIndex = pageNumberOrIndex;
    } else {
      return; // invalid, do nothing
    }

    _currentPage = pageIndex;

    // Also update surah here
    _updateSurahForPageIndex(pageIndex);

    _savePreferences();
    notifyListeners();
  }


  // Navigate to surah
  void navigateToSurah(int surahNumber) {
    if (surahNumber > 0 && surahNumber <= _surahs.length) {
      final surah = _surahs[surahNumber - 1];
      _currentSurah = surahNumber;
      _currentPage = (surah.startPage - 1).clamp(0, quranPages.length - 1);
      _savePreferences();
      notifyListeners();
    }
  }

  // Navigate to ruku
  void navigateToRuku(int rukuNumber) {
    if (rukuNumber > 0) {
      _currentRuku = rukuNumber;
      _currentPage = (rukuNumber - 1).clamp(0, quranPages.length - 1);
      _savePreferences();
      notifyListeners();
    }
  }

  // Get surah by number
  SurahModel? getSurah(int number) {
    return _surahs.firstWhere((s) => s.number == number);
  }

  // Get current surah
  SurahModel get currentSurahModel {
    return _surahs.firstWhere((s) => s.number == _currentSurah, orElse: () => _surahs.first);
  }

  // Play page flip sound
  Future<void> playPageFlipSound() async {
    if (!_soundEnabled) return; // Don't play if sound is off
    try {
      await _audioPlayer.play(AssetSource('audio/page_flip.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add bookmark
  void addBookmark(int page, {String? customTitle, String? customDescription}) {
    final bookmark = BookmarkModel(
      page: page + 1,
      title: customTitle ?? "Page ${page + 1}",
      description: customDescription ?? "Bookmark in $_selectedTheme",
      theme: _selectedTheme,
      createdAt: DateTime.now(),
    );
    
    // Remove existing bookmark for same page if exists
    _bookmarks.removeWhere((b) => b.page == bookmark.page && b.theme == bookmark.theme);
    _bookmarks.add(bookmark);
    _savePreferences();
    notifyListeners();
  }

  // Update bookmark
  void updateBookmark(BookmarkModel oldBookmark, String newTitle, String newDescription) {
    final index = _bookmarks.indexOf(oldBookmark);
    if (index != -1) {
      _bookmarks[index] = BookmarkModel(
        page: oldBookmark.page,
        title: newTitle,
        description: newDescription,
        theme: oldBookmark.theme,
        createdAt: oldBookmark.createdAt,
        timerMinutes: oldBookmark.timerMinutes,
      );
      _savePreferences();
      notifyListeners();
    }
  }

  // Set bookmark timer
  void setBookmarkTimer(BookmarkModel bookmark, int minutes) {
    final index = _bookmarks.indexOf(bookmark);
    if (index != -1) {
      _bookmarks[index] = BookmarkModel(
        page: bookmark.page,
        title: bookmark.title,
        description: bookmark.description,
        theme: bookmark.theme,
        createdAt: bookmark.createdAt,
        timerMinutes: minutes,
      );
      _savePreferences();
      notifyListeners();
    }
  }

  // Remove bookmark
  void removeBookmark(BookmarkModel bookmark) {
    _bookmarks.remove(bookmark);
    _savePreferences();
    notifyListeners();
  }

  // Clear all bookmarks
  void clearAllBookmarks() {
    _bookmarks.clear();
    _savePreferences();
    notifyListeners();
  }

  // Update notification settings
  void updateNotificationSettings(bool enabled, String tone, String title, String description) {
    _notificationsEnabled = enabled;
    _alarmTone = tone;
    _alarmTitle = title;
    _alarmDescription = description;
    _savePreferences();
    notifyListeners();
  }

  // Next page
  void nextPage() {
    if (_currentPage < quranPages.length - 1) {
      _currentPage++;
      playPageFlipSound();
      _savePreferences();
      notifyListeners();
    }
  }

  // Previous page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      playPageFlipSound();
      _savePreferences();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class QuranTheme {
  final String name;
  final String description;
  final String basePath;
  final String filePrefix;
  final String fileExtension;
  final List<int> pageNumbers;

  QuranTheme({
    required this.name,
    required this.description,
    required this.basePath,
    required this.filePrefix,
    required this.fileExtension,
    required this.pageNumbers,
  });
}

class SurahModel {
  final int number;
  final String name;
  final String arabicName;
  final int startPage;
  final int endPage;
  final int verses;

  SurahModel({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.startPage,
    required this.endPage,
    required this.verses,
  });
}

class BookmarkModel {
  final int page;
  final String title;
  final String description;
  final String theme;
  final DateTime createdAt;
  final int? timerMinutes;

  BookmarkModel({
    required this.page,
    required this.title,
    required this.description,
    required this.theme,
    required this.createdAt,
    this.timerMinutes,
  });

  String toJson() {
    return '${page}|${title}|${description}|${theme}|${createdAt.millisecondsSinceEpoch}|${timerMinutes ?? ''}';
  }

  static BookmarkModel fromJson(String json) {
    final parts = json.split('|');
    return BookmarkModel(
      page: int.parse(parts[0]),
      title: parts[1],
      description: parts[2],
      theme: parts[3],
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[4])),
      timerMinutes: parts.length > 5 && parts[5].isNotEmpty ? int.parse(parts[5]) : null,
    );
  }
}