class IslamicOccasion {
  final int month;
  final int day;
  final String titleKey;
  final String messageKey;
  final String? assetPath;

  const IslamicOccasion({
    required this.month,
    required this.day,
    required this.titleKey,
    required this.messageKey,
    this.assetPath,
  });

  static const List<IslamicOccasion> occasions = [
    IslamicOccasion(
      month: 10, // Shawwal
      day: 1,
      titleKey: 'eid_al_fitr_title',
      messageKey: 'eid_al_fitr_message',
    ),
    IslamicOccasion(
      month: 12, // Dhu al-Hijjah
      day: 1,
      titleKey: 'dhu_al_hijjah_title',
      messageKey: 'dhu_al_hijjah_message',
    ),
    IslamicOccasion(
      month: 12, // Dhu al-Hijjah
      day: 10,
      titleKey: 'eid_al_adha_title',
      messageKey: 'eid_al_adha_message',
    ),
    IslamicOccasion(
      month: 1, // Muharram
      day: 1,
      titleKey: 'hijri_new_year_title',
      messageKey: 'hijri_new_year_message',
    ),
  ];
}
