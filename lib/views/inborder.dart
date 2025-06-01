// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
// import 'package:budgify/views/navigation/bottom_nativgation/bottom_navigation_bar.dart';
// import 'package:budgify/core/themes/app_colors.dart';
// import 'package:budgify/viewmodels/currency_symbol.dart';
// import 'package:budgify/viewmodels/lang_provider.dart';
// import 'package:budgify/viewmodels/switchOnOffIncome.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lottie/lottie.dart';

// class AppConstants {
//   static const String onBoardingImageOne = 'assets/cash_fly.json';
//   static const String onBoardingImageTwo = 'assets/save9.json';
//   static const String onBoardingImageThree = 'assets/pppigo.json';
//   static const String onBoardingImageFour = 'assets/money_s.json';

//   static const String onboardingCompletedKey = 'onboarding_completed';
//   static const String currencyKey = 'currency';
//   static const String languageKey = 'language';
//   static const String switchStateKey = 'switchState';

//   static const Duration pageTransitionDuration = Duration(milliseconds: 450);
//   static const Duration dotAnimationDuration = Duration(milliseconds: 300);
//   static const double lottieSize = 250;
//   static const double buttonHorizontalPadding = 24;
//   static const double buttonVerticalPadding = 12;
//   static const double buttonBorderRadius = 8;
//   static const double titleFontSize = 20;
//   static const double buttonFontSize = 16;
//   static const double spacingSmall = 8;
//   static const double spacingMedium = 16;
//   static const double spacingLarge = 20;
//   static const double dotSize = 8;
//   static const int maxBodyLines = 2;
// }

// class OnBoardingModel {
//   final String title;
//   final String body;
//   final String image;
//   const OnBoardingModel({required this.title, required this.body, required this.image});
// }

// class OnBoardingSlider extends StatelessWidget {
//   final PageController pageController;
//   const OnBoardingSlider({super.key, required this.pageController});

//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       controller: pageController,
//       itemCount: onBoardingList.length,
//       physics: const NeverScrollableScrollPhysics(),
//       itemBuilder: (context, index) {
//         final item = onBoardingList[index];
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(item.image, height: AppConstants.lottieSize, width: AppConstants.lottieSize, fit: BoxFit.cover),
//             const SizedBox(height: AppConstants.spacingLarge),
//             Text(item.title.tr, style: const TextStyle(fontSize: AppConstants.titleFontSize, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Colors.white)),
//             const SizedBox(height: AppConstants.spacingSmall),
//             Text(item.body.tr, textAlign: TextAlign.center, maxLines: AppConstants.maxBodyLines, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800)),
//             if (index == 0) const SettingsDropdown(settingType: SettingType.language),
//             if (index == 1) const SettingsDropdown(settingType: SettingType.incomeSwitch),
//             if (index == 2) const SettingsDropdown(settingType: SettingType.currency),
//             if (index == 3) const SizedBox(height: AppConstants.spacingMedium * 2),
//           ],
//         );
//       },
//     );
//   }
// }

// enum SettingType { currency, language, incomeSwitch }

// class SettingsDropdown extends ConsumerStatefulWidget {
//   final SettingType settingType;
//   const SettingsDropdown({super.key, required this.settingType});

//   @override
//   ConsumerState<SettingsDropdown> createState() => _SettingsDropdownState();
// }

// class _SettingsDropdownState extends ConsumerState<SettingsDropdown> {
//   String _localeToLanguage(Locale locale) {
//     const languageMap = {'es': 'Spanish', 'fr': 'French', 'ar': 'Arabic', 'de': 'German', 'zh': 'Chinese', 'pt': 'Portuguese', 'en': 'English'};
//     return languageMap[locale.languageCode] ?? 'English';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentCurrency = ref.watch(currencyProvider).currencySymbol;
//     final currentLocale = ref.watch(languageProvider);
//     final currentLanguage = _localeToLanguage(currentLocale);
//     final isSwitched = ref.watch(switchProvider).isSwitched;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMedium),
//       child: Column(
//         children: [
//           if (widget.settingType == SettingType.currency) _buildCurrencyDropdown(currentCurrency),
//           if (widget.settingType == SettingType.language) _buildLanguageDropdown(currentLanguage),
//           if (widget.settingType == SettingType.incomeSwitch) _buildSwitch(isSwitched),
//         ],
//       ),
//     );
//   }

//   Widget _buildCurrencyDropdown(String? currentValue) {
//     const currencySymbols = ['\$', '€', '£', '¥', 'A\$', 'C\$', 'Fr', '₹', '₩', '₺', '₽', '﷼', 'د.إ', 'E£', 'ج.م'];
//     return DropdownButton<String>(
//       dropdownColor: AppColors.secondaryDarkColor,
//       value: currentValue?.isEmpty ?? true ? null : currentValue,
//       hint: Text('Select Currency'.tr, style: TextStyle(color: Theme.of(context).hintColor)),
//       items: currencySymbols.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
//       onChanged: (value) {
//         if (value != null) {
//           ref.read(currencyProvider.notifier).setCurrencySymbol(value);
//         }
//       },
//     );
//   }

//   Widget _buildLanguageDropdown(String currentValue) {
//     const languages = ['English', 'Spanish', 'French', 'Arabic', 'German', 'Chinese', 'Portuguese'];
//     return DropdownButton<String>(
//       dropdownColor: AppColors.secondaryDarkColor,
//       value: currentValue,
//       hint: Text('Select Language'.tr, style: TextStyle(color: Theme.of(context).hintColor)),
//       items: languages.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
//       onChanged: (value) {
//         if (value != null) {
//           ref.read(languageProvider.notifier).setLanguage(value);
//         }
//       },
//     );
//   }

//   Widget _buildSwitch(bool currentValue) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text('Income Tracking:'.tr),
//         Switch(
//           activeColor: AppColors.accentColor,
//           activeTrackColor: AppColors.accentColor.withOpacity(0.5),
//           value: currentValue,
//           onChanged: (value) {
//             ref.read(switchProvider.notifier).toggleSwitch(value);
//           },
//         ),
//       ],
//     );
//   }
// }

// class OnBoardingDots extends StatelessWidget {
//   final int currentPage;
//   const OnBoardingDots({super.key, required this.currentPage});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(onBoardingList.length, (index) {
//         return AnimatedContainer(
//           duration: AppConstants.dotAnimationDuration,
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           height: AppConstants.dotSize,
//           width: index == currentPage ? AppConstants.dotSize * 2 : AppConstants.dotSize,
//           decoration: BoxDecoration(
//             color: currentPage == index ? AppColors.accentColor : Colors.grey,
//             borderRadius: BorderRadius.circular(AppConstants.dotSize),
//           ),
//         );
//       }),
//     );
//   }
// }

// class OnBoardingButton extends StatelessWidget {
//   final VoidCallback onNext;
//   final String label;
//   const OnBoardingButton({super.key, required this.onNext, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onNext,
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: AppConstants.buttonVerticalPadding, horizontal: AppConstants.buttonHorizontalPadding * 1.5),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius)),
//         backgroundColor: AppColors.accentColor,
//         foregroundColor: Colors.white,
//       ),
//       child: Text(label.tr, style: const TextStyle(fontSize: AppConstants.buttonFontSize, fontWeight: FontWeight.bold)),
//     );
//   }
// }

// class OnBoardingScreen extends ConsumerStatefulWidget {
//   const OnBoardingScreen({super.key});

//   @override
//   ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }

// class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
//   late final PageController _pageController;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _verifyInitialState();
//   }

//   Future<void> _verifyInitialState() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     debugPrint('OnBoarding: Initial state at ${DateTime.now()}');
//     debugPrint('OnBoarding: onboarding_completed: ${prefs.getBool(AppConstants.onboardingCompletedKey)}');
//     debugPrint('OnBoarding: Currency: ${prefs.getString(AppConstants.currencyKey)}');
//     debugPrint('OnBoarding: Language: ${prefs.getString(AppConstants.languageKey)}');
//     debugPrint('OnBoarding: Switch state: ${prefs.getBool(AppConstants.switchStateKey)}');
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   Future<void> _next() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.reload();
//     bool validationPassed = true;

//     if (_currentPage == 0) {
//       final language = ref.read(languageProvider).languageCode;
//       if (language.isEmpty) {
//         _showSnackBar(context, 'Please select a language'.tr);
//         validationPassed = false;
//       }
//     } else if (_currentPage == 2) {
//       final currentCurrency = ref.read(currencyProvider).currencySymbol;
//       if (currentCurrency.isEmpty) {
//         _showSnackBar(context, 'Please Choose the Currency Symbol'.tr);
//         validationPassed = false;
//       }
//     }

//     if (!validationPassed) {
//       return;
//     }

//     if (_currentPage == onBoardingList.length - 1) {
//       await _completeOnboarding(prefs);
//     } else {
//       _goToNextPage();
//     }
//   }

//   Future<void> _completeOnboarding(SharedPreferences prefs) async {
//     try {
//       bool settingsSaved = false;
//       int retryCount = 0;
//       const int maxRetries = 3;

//       while (!settingsSaved && retryCount < maxRetries) {
//         try {
//           await _saveAllSettings(prefs);
//           settingsSaved = true;
//         } catch (e) {
//           retryCount++;
//           debugPrint('OnBoarding: Failed to save settings (attempt $retryCount): $e');
//           if (retryCount < maxRetries) {
//             await Future.delayed(const Duration(milliseconds: 500));
//           }
//         }
//       }

//       if (!settingsSaved) {
//         debugPrint('OnBoarding: ERROR - Failed to save settings after $maxRetries attempts');
//         _showSnackBar(context, 'Failed to save settings. Please try again.'.tr);
//         return;
//       }

//       await prefs.setBool(AppConstants.onboardingCompletedKey, true);
//       await prefs.reload();
//       final isCompleted = prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
//       debugPrint('OnBoarding: Set onboarding_completed to true, verified: $isCompleted');

//       if (!isCompleted) {
//         debugPrint('OnBoarding: ERROR - Failed to set onboarding_completed flag');
//         _showSnackBar(context, 'Error saving onboarding status. Please try again.'.tr);
//         return;
//       }

//       debugPrint('OnBoarding: Final settings - Currency: ${prefs.getString(AppConstants.currencyKey)}, Language: ${prefs.getString(AppConstants.languageKey)}, Switch: ${prefs.getBool(AppConstants.switchStateKey)}');

//       if (mounted) {
//         Get.offAll(() => const Bottom(), transition: Transition.fade);
//         debugPrint('OnBoarding: Navigated to Bottom screen at ${DateTime.now()}');
//       }
//     } catch (e) {
//       debugPrint('OnBoarding: Error completing onboarding: $e');
//       _showSnackBar(context, 'Error saving settings. Please try again.'.tr);
//     }
//   }

//   Future<void> _saveAllSettings(SharedPreferences prefs) async {
//     try {
//       final currency = ref.read(currencyProvider).currencySymbol;
//       await prefs.setString(AppConstants.currencyKey, currency);
//       await prefs.reload();
//       final savedCurrency = prefs.getString(AppConstants.currencyKey);
//       if (savedCurrency != currency) {
//         throw Exception('Failed to save currency: expected $currency, got $savedCurrency');
//       }

//       final locale = ref.read(languageProvider);
//       await prefs.setString(AppConstants.languageKey, locale.languageCode);
//       await prefs.reload();
//       final savedLanguage = prefs.getString(AppConstants.languageKey);
//       if (savedLanguage != locale.languageCode) {
//         throw Exception('Failed to save language: expected ${locale.languageCode}, got $savedLanguage');
//       }

//       final isSwitched = ref.read(switchProvider).isSwitched;
//       await prefs.setBool(AppConstants.switchStateKey, isSwitched);
//       await prefs.reload();
//       final savedSwitchState = prefs.getBool(AppConstants.switchStateKey);
//       if (savedSwitchState != isSwitched) {
//         throw Exception('Failed to save switch state: expected $isSwitched, got $savedSwitchState');
//       }

//       debugPrint('OnBoarding: Successfully saved settings - Currency: $currency, Language: ${locale.languageCode}, Switch: $isSwitched');
//     } catch (e) {
//       debugPrint('OnBoarding: Error saving settings: $e');
//       rethrow;
//     }
//   }

//   void _goToNextPage() {
//     setState(() => _currentPage++);
//     _pageController.animateToPage(
//       _currentPage,
//       duration: AppConstants.pageTransitionDuration,
//       curve: Curves.easeInOut,
//     );
//   }

//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: AppColors.accentColor2,
//         content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLastPage = _currentPage == onBoardingList.length - 1;
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               flex: 3,
//               child: OnBoardingSlider(pageController: _pageController),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppConstants.spacingMedium,
//                 vertical: AppConstants.spacingLarge,
//               ),
//               child: Column(
//                 children: [
//                   OnBoardingDots(currentPage: _currentPage),
//                   const SizedBox(height: AppConstants.spacingLarge * 2),
//                   OnBoardingButton(
//                     onNext: _next,
//                     label: isLastPage ? 'Get Started' : 'Next',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// const onBoardingList = [
//   OnBoardingModel(
//     title: "Manage Finances",
//     body: "Organize expenses by category \n and choose your language for a \n personalized experience.",
//     image: AppConstants.onBoardingImageFour,
//   ),
//   OnBoardingModel(
//     title: "Control Income Tracking",
//     body: "Easily turn on or off income tracking \n based on your preferences. Stay focused \n on what matters to you.",
//     image: AppConstants.onBoardingImageTwo,
//   ),
//   OnBoardingModel(
//     title: "Track Your Expenses",
//     body: "Easily monitor where your money goes \n Select your preferred currency to \n get started and stay in control.",
//     image: AppConstants.onBoardingImageOne,
//   ),
//   OnBoardingModel(
//     title: "Save Money Wisely",
//     body: "Reach your financial goals faster. \n Let's get started!",
//     image: AppConstants.onBoardingImageThree,
//   ),
// ];