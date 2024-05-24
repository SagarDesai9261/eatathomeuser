class Translations {
  static final languages = <String>[
    'English',
    'vietnamese',
    'French',
    'French (Canada)',
    'Spanish',
    'Korean',
    'Arabic'
  ];

  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'vietnamese':
        return 'vi';
      case 'French':
        return 'fr';
      case 'French (Canada)':
        return 'fr_CA';
      case 'Spanish':
        return 'es';
      case 'Korean':
        return 'ko';
      case 'Arabic':
        return 'ar';
      default:
        return 'en';
    }
  }
}
