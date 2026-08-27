class LanguagePreference {
  final String languageCode;
  final String? countryCode;

  const LanguagePreference(this.languageCode, [this.countryCode]);

  static const englishUnitedStates = LanguagePreference('en', 'US');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePreference &&
          languageCode == other.languageCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(languageCode, countryCode);
}
