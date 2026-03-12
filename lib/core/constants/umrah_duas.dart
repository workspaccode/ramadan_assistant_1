import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:ramadan_assistant/data/models/dua_model.dart';

class UmrahDuas {
  static final DuaService _duaService = sl<DuaService>();

  static Dua get ishtirat => _duaService.allDuas.firstWhere(
        (d) => d.category == 'إحرام' && d.arabic.contains('مَحِلِّي'),
        orElse: () => const Dua(
          category: 'إحرام',
          arabic: 'اللَّهُمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي',
          translation: 'O Allah, my place of leaving Ihram is where You have held me back.',
        ),
      );

  static const String ishtiratFull =
      'اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي، نَوَيْتُ الْعُمْرَةَ وَأَحْرَمْتُ بِهَا لِلَّهِ تَعَالَى، فَإِنْ حَبَسَنِي حَابِسٌ فَمَحِلِّي حَيْثُ حَبَسْتَنِي';

  static const String ishtiratInfo =
      'هذا الدعاء يُسمى \'دعاء الاشتراط\'، وهو مهم جدًا لمن يخشى ألا يستطيع إكمال العمرة لسبب طارئ (مثل مرض، تعب مفاجئ، أو أي ظرف يمنعه). إذا قلت هذا الدعاء ومنعك مانع، يجوز لك أن تخلع الإحرام وتعود لحياتك الطبيعية دون أن يكون عليك أي فدية (ذبح هدي).';

  /// Gets Duas for specific Sai category
  static List<Dua> get saiDuas => _duaService.getByCategory('سعي');

  /// Gets Duas for Tawaf/Sai rounds (mabrur/fixed)
  static List<Dua> get tawafSaiDuas => [
        ..._duaService.getByCategory('أذكار ثابتة في الطواف'),
        ..._duaService.getByCategory('أدعية مأثورة'),
        ..._duaService.getByCategory('أدعية جامعة'),
      ];

  /// Arabic ordinal names for the 7 Tawaf rounds
  static const List<String> tawafRoundNames = [
    'الشوط الأول',
    'الشوط الثاني',
    'الشوط الثالث',
    'الشوط الرابع',
    'الشوط الخامس',
    'الشوط السادس',
    'الشوط السابع',
  ];

  /// Fixed duas that appear in EVERY round
  static List<Dua> get _fixedRoundDuas =>
      _duaService.getByCategory('أذكار ثابتة في الطواف')
          .where((d) => d.arabic.contains('إيماناً بك') || d.arabic.contains('حسنة'))
          .toList();

  /// Gets the full list of Duas for each of the 7 Tawaf rounds
  static List<List<Dua>> get tawafRoundDuas {
    final generalDuas = [
        ..._duaService.getByCategory('أدعية مأثورة'),
        ..._duaService.getByCategory('أدعية جامعة'),
    ];

    return List.generate(7, (roundIndex) {
      final startIndex = (roundIndex * 3) % (generalDuas.isEmpty ? 1 : generalDuas.length);
      final count = 3;
      
      List<Dua> selectedGeneral = [];
      if (generalDuas.isNotEmpty) {
        for (int i = 0; i < count; i++) {
          selectedGeneral.add(generalDuas[(startIndex + i) % generalDuas.length]);
        }
      }

      return [..._fixedRoundDuas, ...selectedGeneral];
    });
  }

  /// Same for Sai
  static const List<String> saiRoundNames = tawafRoundNames;

  /// Fixed duas that appear in EVERY Sai round
  static List<Dua> get _fixedSaiRoundDuas => [
        ..._duaService.getByCategory('آية السعي'),
        ..._duaService.getByCategory('التكبير والتهليل'),
      ];

  /// Gets the specific duas for a Sai round by its index (0-6).
  static List<Dua> getSaiRoundDuas(int roundIndex) {
    if (roundIndex < 0 || roundIndex > 6) return [];

    final roundName = tawafRoundNames[roundIndex]; // 'الشوط الأول' etc.
    final specificDuas = _duaService.getByCategory(roundName);

    return [..._fixedSaiRoundDuas, ...specificDuas];
  }
}
