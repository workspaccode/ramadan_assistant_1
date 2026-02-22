class HadithModel {
  final String id;
  final String arabic;
  final String translation;
  final String urdu;
  final String source;

  const HadithModel({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.urdu,
    required this.source,
  });
}

class HadithPresets {
  static const List<HadithModel> hadithList = [
    HadithModel(
      id: '1',
      arabic:
          'قَالَ رَسُولُ اللَّهِ ﷺ: "مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ"',
      translation:
          'The Messenger of Allah (ﷺ) said: "Whoever fasts Ramadan out of faith and in the hope of reward, his previous sins will be forgiven."',
      urdu:
          'رسول اللہ ﷺ نے فرمایا: ”جس نے رمضان کے روزے ایمان اور ثواب کی نیت سے رکھے، اس کے پچھلے گناہ معاف کر دیے جائیں گے۔“',
      source: 'Sahih Bukhari & Muslim',
    ),
    HadithModel(
      id: '2',
      arabic:
          'قَالَ رَسُولُ اللَّهِ ﷺ: "إِذَا جَاءَ رَمَضَانُ فُتِحَتْ أَبْوَابُ الْجَنَّةِ، وَغُلِّقَتْ أَبْوَابُ النَّارِ، وَصُفِّدَتِ الشَّيَاطِينُ"',
      translation:
          'The Messenger of Allah (ﷺ) said: "When Ramadan begins, the gates of Paradise are opened, the gates of Hell are closed, and the devils are chained."',
      urdu:
          'رسول اللہ ﷺ نے فرمایا: ”جب رمضان شروع ہوتا ہے تو جنت کے دروازے کھول دیے جاتے ہیں، جہنم کے دروازے بند کر دیے جاتے ہیں اور شیاطین کو جکڑ دیا جاتا ہے۔“',
      source: 'Sahih Bukhari & Muslim',
    ),
    HadithModel(
      id: '3',
      arabic:
          'قَالَ رَسُولُ اللَّهِ ﷺ: "تَسَحَّرُوا فَإِنَّ فِي السُّحُورِ بَرَكَةً"',
      translation:
          'The Messenger of Allah (ﷺ) said: "Take Suhoor (pre-dawn meal), for in Suhoor there is blessing."',
      urdu: 'رسول اللہ ﷺ نے فرمایا: ”سحری کھایا کرو کیونکہ سحری میں برکت ہے۔“',
      source: 'Sahih Bukhari & Muslim',
    ),
    HadithModel(
      id: '4',
      arabic:
          'قَالَ رَسُولُ اللَّهِ ﷺ: "لاَ يَزَالُ النَّاسُ بِخَيْرٍ مَا عَجَّلُوا الْفِطْرَ"',
      translation:
          'The Messenger of Allah (ﷺ) said: "People will continue to be in a good state as long as they hasten the breaking of the fast."',
      urdu:
          'رسول اللہ ﷺ نے فرمایا: ”لوگ ہمیشہ خیر پر رہیں گے جب تک وہ افطار میں جلدی کریں گے۔“',
      source: 'Sahih Bukhari & Muslim',
    ),
    HadithModel(
      id: '5',
      arabic:
          'قَالَ رَسُولُ اللَّهِ ﷺ: "مَنْ لَمْ يَدَعْ قَوْلَ الزُّورِ وَالْعَمَلَ بِهِ فَلَيْسَ لِلَّهِ حَاجَةٌ فِي أَنْ يَدَعَ طَعَامَهُ وَشَرَابَهُ"',
      translation:
          'The Messenger of Allah (ﷺ) said: "Whoever does not give up false speech and acting upon it, Allah has no need of his giving up his food and drink."',
      urdu:
          'رسول اللہ ﷺ نے فرمایا: ”جس نے جھوٹ بولنا اور اس پر عمل کرنا نہ چھوڑا، اللہ کو اس کی کوئی ضرورت نہیں کہ وہ اپنا کھانا پینا چھوڑ دے۔“',
      source: 'Sahih Bukhari',
    ),
  ];
}
