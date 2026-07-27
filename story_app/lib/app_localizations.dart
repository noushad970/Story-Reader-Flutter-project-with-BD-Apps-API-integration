import 'package:flutter/material.dart';

/// Holds all UI strings in both English and Bangla.
///
/// Lookups go through `AppLocalizations.of(context)`; the current locale is
/// driven by [LocaleProvider] which the user can toggle from the header.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('bn')];

  bool get isBangla => locale.languageCode == 'bn';

  // ============================================================
  // GENERIC
  // ============================================================
  String get appTitle => 'Story Reader';
  String get welcomeBack => 'Welcome back';
  String get loading => 'Loading...';
  String get retry => 'Retry';
  String get cancel => 'Cancel';
  String get ok => 'OK';

  // ============================================================
  // HOME
  // ============================================================
  String get homeGreeting => welcomeBack;
  String get homeSubtitle => 'Story Reader';
  String get searchHint => isBangla
      ? 'গল্প, লেখক, ক্যাটাগরি খুঁজুন...'
      : 'Search stories, authors, categories...';
  String get allCategory => 'All';
  String get noStoriesFound =>
      isBangla ? 'কোনো গল্প পাওয়া যায়নি' : 'No stories found';
  String get tryDifferentSearch => isBangla
      ? 'অন্য কোনো শব্দ দিয়ে চেষ্টা করুন'
      : 'Try a different search term';
  String get checkBackLater => isBangla
      ? 'নতুন গল্পের জন্য আবার দেখুন'
      : 'Check back later for new stories';
  String get loadMore => isBangla ? 'আরো দেখুন' : 'Load more';
  String get failedLoadCategories =>
      isBangla ? 'ক্যাটাগরি লোড করা যায়নি' : 'Failed to load categories';
  String get tooltipHome => isBangla ? 'হোম' : 'Home';
  String get tooltipBookmarks => isBangla ? 'সংরক্ষিত গল্প' : 'Saved stories';
  String get tooltipUnsubscribe => isBangla ? 'আনসাবস্ক্রাইব' : 'Unsubscribe';
  String get tooltipTheme => isBangla ? 'থিম পরিবর্তন' : 'Toggle theme';
  String get tooltipLanguage => isBangla ? 'ভাষা পরিবর্তন' : 'Change language';
  String get unsubscribeTitle =>
      isBangla ? 'আনসাবস্ক্রাইব করবেন?' : 'Unsubscribe?';
  String get unsubscribeBody => isBangla
      ? 'আপনি সাবস্ক্রাইবার গল্পে অ্যাক্সেস হারাবেন।'
      : 'You will lose access to subscriber stories.';
  String get unsubscribeConfirm => isBangla ? 'আনসাবস্ক্রাইব' : 'UNSUBSCRIBE';
  String get unsubscribeFailed =>
      isBangla ? 'আনসাবস্ক্রাইব ব্যর্থ হয়েছে' : 'Unsubscribe failed';

  // ============================================================
  // BOOKMARKS
  // ============================================================
  String get bookmarksTitle => isBangla ? 'সংরক্ষিত গল্প' : 'Saved Stories';
  String get bookmarksEmptyTitle =>
      isBangla ? 'এখনো কোনো গল্প সংরক্ষিত হয়নি' : 'No saved stories yet';
  String get bookmarksEmptyBody => isBangla
      ? 'যেকোনো গল্পে বুকমার্ক আইকনে টোকা দিয়ে সংরক্ষণ করুন।'
      : 'Tap the bookmark icon on any story to save it.';
  String get goToHome => isBangla ? 'হোমে যান' : 'Go to Home';
  String get bookmarksLoginRequired => isBangla
      ? 'সংরক্ষিত গল্প দেখতে লগইন করুন।'
      : 'Please log in to see saved stories.';

  // ============================================================
  // COMMENTS
  // ============================================================
  String get commentsTitle => isBangla ? 'মন্তব্য' : 'Comments';
  String get noCommentsYet =>
      isBangla ? 'এখনো কোনো মন্তব্য নেই' : 'No comments yet';
  String get beFirstComment => isBangla
      ? 'প্রথম মন্তব্যটি আপনি করুন'
      : 'Be the first to share your thoughts';
  String get writeCommentHint =>
      isBangla ? 'একটি মন্তব্য লিখুন...' : 'Write a comment...';
  String get postCommentFailed =>
      isBangla ? 'মন্তব্য পোস্ট করা যায়নি' : 'Failed to post comment';
  String get pleaseLoginToComment =>
      isBangla ? 'মন্তব্য করতে লগইন করুন' : 'Please log in to comment';

  // ============================================================
  // STORY DETAILS
  // ============================================================
  String byAuthor(String author) => isBangla ? 'লেখক: $author' : 'By $author';
  String get like => isBangla ? 'লাইক' : 'Like';
  String get comments => isBangla ? 'মন্তব্য' : 'Comments';
  String get save => isBangla ? 'সংরক্ষণ' : 'Save';
  String get saved => isBangla ? 'সংরক্ষিত' : 'Saved';
  String get savedToBookmarks =>
      isBangla ? 'বুকমার্কে সংরক্ষিত হয়েছে' : 'Saved to bookmarks';
  String get removedFromBookmarks =>
      isBangla ? 'বুকমার্ক থেকে সরানো হয়েছে' : 'Removed from bookmarks';
  String get bookmarkFailed =>
      isBangla ? 'বুকমার্ক ব্যর্থ হয়েছে' : 'Bookmark failed';
  String get likeFailed => isBangla ? 'লাইক ব্যর্থ হয়েছে' : 'Like failed';
  String get pleaseLoginToLike =>
      isBangla ? 'লাইক করতে লগইন করুন' : 'Please log in to like';
  String get pleaseLoginToBookmark =>
      isBangla ? 'বুকমার্ক করতে লগইন করুন' : 'Please log in to bookmark';
  String get tooltipRemoveBookmark =>
      isBangla ? 'বুকমার্ক সরান' : 'Remove bookmark';
  String get tooltipBookmark => isBangla ? 'বুকমার্ক করুন' : 'Bookmark';

  // ============================================================
  // LANDING SCREEN
  // ============================================================
  String get landingHeroTitle =>
      isBangla ? 'অসাধারণ গল্প পড়ুন' : 'Read Amazing Stories';
  String get landingDescription => isBangla
      ? 'রোমান্টিক, রহস্য, অ্যাডভেঞ্চার আর অনেক রকমের গল্প — নতুন দুনিয়া আবিষ্কার করুন।'
      : 'Explore exciting stories, discover new worlds, and enjoy unlimited reading with our premium collection.';
  String get featureUnlimitedStories =>
      isBangla ? 'সীমাহীন গল্প' : 'Unlimited Stories';
  String get featureUnlimitedStoriesDesc => isBangla
      ? 'আমাদের বাড়তে থাকা গল্পের কালেকশন পড়ুন।'
      : 'Read our growing collection of stories.';
  String get featureMultipleCategories =>
      isBangla ? 'অনেক ক্যাটাগরি' : 'Multiple Categories';
  String get featureMultipleCategoriesDesc => isBangla
      ? 'অ্যাডভেঞ্চার, রোমান্স, মিস্ট্রি, থ্রিলার এবং আরো অনেক।'
      : 'Adventure, romance, mystery, thriller and more.';
  String get featureEasyMobileAuth =>
      isBangla ? 'সহজ মোবাইল অথেন্টিকেশন' : 'Easy Mobile Authentication';
  String get featureEasyMobileAuthDesc => isBangla
      ? 'আপনার মোবাইল নম্বর দিয়ে সাবস্ক্রাইব করুন।'
      : 'Subscribe using your mobile number.';
  String get premiumBadge => isBangla ? 'প্রিমিয়াম' : 'PREMIUM';
  String get subscriptionTitle => isBangla ? 'সাবস্ক্রিপশন' : 'Subscription';
  String get subscriptionDescription => isBangla
      ? 'প্রতিদিন সীমাহীন প্রিমিয়াম গল্প উপভোগ করুন।'
      : 'Enjoy unlimited premium stories every day.';
  String get pricePerDay => isBangla ? '\u{09F3}২' : '\u{09F3}2';
  String get perDay => isBangla ? '/ দিন' : '/ day';
  String get subscribeNow => isBangla ? 'সাবস্ক্রাইব করুন' : 'SUBSCRIBE NOW';
  String copyright(int year) =>
      isBangla ? '\u{00A9} $year গল্প পড়ুন' : '\u{00A9} $year Story Reader';

  // ============================================================

  // ============================================================
  // SUBSCRIPTION SCREEN
  // ============================================================
  String get subscriptionHeroTitle => isBangla
      ? 'প্রতিদিন \u{09F3}২ টাকা দিয়ে সাবস্ক্রাইব করুন'
      : 'Subscribe for \u{09F3}2 per day';
  String get subscriptionHeroSubtitle => isBangla
      ? 'সাবস্ক্রিপশন চালিয়ে যাওয়ার জন্য আপনার বাংলাদেশি মোবাইল নম্বর দিন।'
      : 'Enter your Bangladesh mobile number to continue with subscription.';
  String get premiumBadgeShort => isBangla ? 'প্রিমিয়াম' : 'PREMIUM';
  String get unlimitedAccessBadge => isBangla
      ? 'সব ক্যাটাগরিতে সীমাহীন অ্যাক্সেস'
      : 'Unlimited access to all stories & categories';
  String get mobileNumberLabel => isBangla ? 'মোবাইল নম্বর' : 'Mobile Number';
  String get mobileNumberHint => isBangla ? '০১XXXXXXXXX' : '018XXXXXXXX';
  String get sendOtpCta => isBangla ? 'ওটিপি পাঠান' : 'SEND OTP';
  String get otpChargesNotice =>
      isBangla ? 'ওটিপির চার্জ প্রযোজ্য হতে পারে' : 'OTP charges may apply';
  String get enterBangladeshMobile => isBangla
      ? 'একটি সঠিক বাংলাদেশি মোবাইল নম্বর দিন'
      : 'Enter a valid Bangladesh mobile number';
  String get referenceNumberMissing => isBangla
      ? 'রেফারেন্স নম্বর পাওয়া যায়নি'
      : 'Reference number was not received';
  String get otpRequestFailed =>
      isBangla ? 'ওটিপি অনুরোধ ব্যর্থ হয়েছে' : 'OTP request failed';
  String get pleaseEnterOtp =>
      isBangla ? 'অনুগ্রহ করে ওটিপি দিন' : 'Please enter the OTP';
  String get changeMobileNumber =>
      isBangla ? 'মোবাইল নম্বর পরিবর্তন করুন' : 'Change Mobile Number';
  String get verifyOtpCta => isBangla ? 'ওটিপি যাচাই করুন' : 'VERIFY OTP';
  String get enterOtpHero => isBangla ? 'ওটিপি দিন' : 'Enter OTP';
  // ============================================================
  // PHONE LOGIN
  // ============================================================
  String get phoneLoginTitle =>
      isBangla ? 'আপনার মোবাইল নম্বর দিন' : 'Enter your mobile number';
  String get phoneHint =>
      isBangla ? 'মোবাইল নম্বর (০১XXXXXXXXX)' : 'Mobile number (01XXXXXXXXX)';
  String get sendOtp => isBangla ? 'ওটিপি পাঠান' : 'Send OTP';
  String get invalidPhone => isBangla
      ? 'অনুগ্রহ করে একটি মোবাইল নম্বর দিন'
      : 'Please enter a valid mobile number';
  String get otpSendFailed =>
      isBangla ? 'ওটিপি পাঠানো যায়নি' : 'Failed to send OTP';

  // ============================================================
  // OTP
  // ============================================================
  String get otpTitle => isBangla ? 'ওটিপি যাচাই করুন' : 'Verify OTP';
  String get otpHint =>
      isBangla ? '৬ ডিজিটের ওটিপি লিখুন' : 'Enter 6 digit OTP';
  String get otpLengthError => isBangla
      ? 'ওটিপি অবশ্যই ৪ থেকে ৬ ডিজিটের হতে হবে'
      : 'OTP must be 4 to 6 digits';
  String get verifyOtp => isBangla ? 'যাচাই করুন' : 'Verify';
  String get verifyOtpFailed =>
      isBangla ? 'ওটিপি যাচাই ব্যর্থ হয়েছে' : 'OTP verification failed';
  String get resendOtp => isBangla ? 'ওটিপি আবার পাঠান' : 'Resend OTP';
  String get otpSentTo => isBangla ? 'ওটিপি পাঠানো হয়েছে:' : 'OTP sent to:';

  // ============================================================
  // ADMIN
  // ============================================================
  String get adminLoginTitle => isBangla ? 'অ্যাডমিন লগইন' : 'Admin login';
  String get adminPanel => isBangla ? 'অ্যাডমিন প্যানেল' : 'Admin panel';
  String get adminOtpTitle =>
      isBangla ? 'অ্যাডমিন ওটিপি যাচাই' : 'Admin OTP verification';
  String get logout => isBangla ? 'লগআউট' : 'Logout';

  // ============================================================
  // LANG TOGGLE LABEL
  // ============================================================
  String get languageName => isBangla ? 'বাংলা' : 'English';
  String get switchToLanguage => isBangla ? 'English' : 'বাংলা';

  // ============================================================
  // SNACKBAR GENERIC
  // ============================================================
  String get networkError => isBangla
      ? 'নেটওয়ার্ক সমস্যা। আবার চেষ্টা করুন।'
      : 'Network error. Please try again.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
