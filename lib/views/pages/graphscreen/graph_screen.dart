// lib/views/pages/graphscreen/charts_screen.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/pages/celender_screen.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'package:budgify/views/pages/graphscreen/card_chart.dart';
import 'package:budgify/views/pages/graphscreen/category_list_chart_merge_income_expense.dart';
import 'package:budgify/views/pages/graphscreen/category_list_chart_page.dart';
import 'package:budgify/views/pages/graphscreen/reports_tables/day_report_table.dart';
import 'package:budgify/views/pages/graphscreen/reports_tables/month_report_table.dart';
import 'package:budgify/views/pages/graphscreen/reports_tables/year_report_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

// Your ScaleConfig and ThemeContext extensions are fine, no changes needed.
// I will include them here for completeness of the file.
extension ThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get appTextTheme => Theme.of(this).textTheme;
  ScaleConfig get scaleConfig => ScaleConfig(this);
}

class ScaleConfig {
  final double referenceWidth;
  final double referenceHeight;
  final double referenceDPI;
  final double screenWidth;
  final double screenHeight;
  final double scaleWidth;
  final double scaleHeight;
  final double textScaleFactor;
  final Orientation orientation;
  final double devicePixelRatio;

  ScaleConfig._({
    required this.referenceWidth,
    required this.referenceHeight,
    required this.referenceDPI,
    required this.screenWidth,
    required this.screenHeight,
    required this.scaleWidth,
    required this.scaleHeight,
    required this.textScaleFactor,
    required this.orientation,
    required this.devicePixelRatio,
  });

  factory ScaleConfig(
    BuildContext context, {
    double refWidth = 375,
    double refHeight = 812,
    double refDPI = 326,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final orientation = mediaQuery.orientation;
    final textScale = mediaQuery.textScaleFactor;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    return ScaleConfig._(
      referenceWidth: refWidth,
      referenceHeight: refHeight,
      referenceDPI: refDPI,
      screenWidth: width,
      screenHeight: height,
      scaleWidth: width / refWidth,
      scaleHeight: height / refHeight,
      textScaleFactor: textScale,
      orientation: orientation,
      devicePixelRatio: devicePixelRatio,
    );
  }

  double get scaleFactor {
    final baseScale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    final dpiRatio = devicePixelRatio / (referenceDPI / 160);
    final dpiScale = 1.0 + (dpiRatio - 1.0) * 0.05;
    final landscapeMultiplier =
        orientation == Orientation.landscape ? 1.05 : 1.0;
    return baseScale * dpiScale * landscapeMultiplier;
  }

  double scale(double size) {
    return (size * scaleFactor).clamp(size * 0.8, size * 2.0);
  }

  double scaleText(double fontSize) {
    double adjustedTextScaleFactor = textScaleFactor.clamp(0.7, 1.5);
    double scaledSize = fontSize * scaleFactor * adjustedTextScaleFactor;

    if (devicePixelRatio > 3.0) {
      scaledSize *= 0.85;
    } else if (devicePixelRatio > 2.5) {
      scaledSize *= 0.9;
    }

    return scaledSize.clamp(fontSize * 0.7, fontSize * 1.3);
  }

  bool get isTablet {
    final shortestSide =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final longestSide = screenWidth > screenHeight ? screenWidth : screenHeight;
    return shortestSide > 600 && longestSide > 900;
  }

  double tabletScale(double size) {
    final baseScaledSize = scale(size);
    if (isTablet) {
      return baseScaledSize * 1.1;
    }
    return baseScaledSize;
  }

  double tabletScaleText(double fontSize) {
    final baseScaledSize = scaleText(fontSize);
    if (isTablet) {
      return baseScaledSize * 1.1;
    }
    return baseScaledSize;
  }

  double widthPercentage(double percentage) {
    return screenWidth * percentage;
  }
}

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen>
    with TickerProviderStateMixin {
  late TabController _monthTabController;
  late TabController _dayTabController;
  late TabController _yearTabController;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;

  bool showYearTabs = false;
  bool showMonthTabs = true;
  bool showDayTabs = true;

  int chartType = 0;
  int incomeType = 0;

  final GlobalKey _filterIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _monthTabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: selectedMonth - 1,
    );
    _yearTabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: (selectedYear - 2022).clamp(0, 5),
    );
    _dayTabController = TabController(
      length: getDaysInMonth(selectedMonth, selectedYear),
      vsync: this,
      initialIndex: selectedDay - 1,
    );

    _monthTabController.addListener(_monthTabListener);
    _yearTabController.addListener(_yearTabListener);
    _dayTabController.addListener(_dayTabListener);
  }

  void _monthTabListener() {
    if (_monthTabController.indexIsChanging) {
      setState(() {
        selectedMonth = _monthTabController.index + 1;
        selectedDay = 1;
        updateDayTabController();
      });
    }
  }

  void _yearTabListener() {
    if (_yearTabController.indexIsChanging) {
      setState(() {
        selectedYear = 2022 + _yearTabController.index;
        selectedDay = 1;
        updateDayTabController();
      });
    }
  }

  void _dayTabListener() {
    if (_dayTabController.indexIsChanging) {
      setState(() {
        selectedDay = _dayTabController.index + 1;
      });
    }
  }

  void updateDayTabController() {
    if (showDayTabs) {
      final newDayCount = getDaysInMonth(selectedMonth, selectedYear);
      final newIndex = (selectedDay - 1).clamp(0, newDayCount - 1);

      _dayTabController.removeListener(_dayTabListener);
      _dayTabController.dispose();
      _dayTabController = TabController(
        length: newDayCount,
        vsync: this,
        initialIndex: newIndex,
      );
      _dayTabController.addListener(_dayTabListener);
    }
  }

  double calculateAppBarHeight(ScaleConfig scaleConfig) {
    int visibleTabs = 0;
    if (showYearTabs) visibleTabs++;
    if (showMonthTabs) visibleTabs++;
    if (showDayTabs) visibleTabs++;

    switch (visibleTabs) {
      case 1:
        return scaleConfig.scale(50);
      case 2:
        return scaleConfig.scale(85);
      case 3:
        return scaleConfig.scale(125);
      default:
        return scaleConfig.scale(50);
    }
  }

  void _updateCheckboxState({bool? year, bool? month, bool? day}) {
    Navigator.of(context).pop();
    setState(() {
      if (year != null) showYearTabs = year;
      if (month != null) {
        showMonthTabs = month;
        if (!month) showDayTabs = false;
      }
      if (day != null) showDayTabs = day;

      if (!showYearTabs && !showMonthTabs && !showDayTabs) {
        showYearTabs = true;
      }
      if (showDayTabs && chartType == 2) {
        chartType = 0;
      }
    });
  }

  @override
  void dispose() {
    _monthTabController.removeListener(_monthTabListener);
    _yearTabController.removeListener(_yearTabListener);
    _dayTabController.removeListener(_dayTabListener);
    _monthTabController.dispose();
    _dayTabController.dispose();
    _yearTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleConfig = ScaleConfig(context);
    final cardColor = Theme.of(context).scaffoldBackgroundColor;
    final switchState = ref.watch(switchProvider).isSwitched;
    bool isArabic =
        ref.watch(languageProvider).toString() == 'ar' ? true : false;

    // --- Get all necessary currency information ---
    final allWallets = ref.watch(walletProvider);
    final currentDisplayCurrency = ref.watch(currencyProvider).displayCurrency;

    // Get unique currency codes from wallets
    final usedCurrencyCodes = allWallets.map((w) => w.currencyCode).toSet();

    // Find the full Currency objects for the used codes
    final usedCurrencies = usedCurrencyCodes
        .map((code) => availableCurrencies.firstWhere((c) => c.code == code,
            orElse: () => currentDisplayCurrency))
        .toList();

    // Determine the current value for the dropdown
    final String? dropdownValue =
        usedCurrencyCodes.contains(currentDisplayCurrency.code)
            ? currentDisplayCurrency.code
            : (usedCurrencyCodes.isNotEmpty ? usedCurrencyCodes.first : null);

    return Scaffold(
      appBar: AppBar(
        // --- UPDATED SECTION START ---
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (usedCurrencies.length > 1 && dropdownValue != null)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    // This creates a tiny, almost invisible arrow for better UX
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        size: scaleConfig.scaleText(2)),
                    dropdownColor: Theme.of(context).cardTheme.color,
                    // This builder defines how the selected item looks on the AppBar
                    selectedItemBuilder: (context) {
                      return usedCurrencies.map<Widget>((currency) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: scaleConfig.scale(4)),
                            child: Text(
                              currency.symbol, // Show only the symbol
                              style: TextStyle(
                                  color:
                                      AppColors.dividerColor, // Consistent color
                                  fontSize: scaleConfig.scaleText(18),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    // This builder defines how the items look inside the dropdown list
                    items: usedCurrencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency.code,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currency.symbol} ', // Symbol with space
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: scaleConfig.scaleText(15),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currency.code, // Clean currency code
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: scaleConfig.scaleText(13),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        ref
                            .read(currencyProvider.notifier)
                            .changeDisplayCurrency(newCode);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        // --- UPDATED SECTION END ---
        leadingWidth: 100,
        title: Text(
          "Charts Page".tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textColorDarkTheme,
          ),
        ),
        actions: [
          if (switchState)
            Padding(
              padding: EdgeInsets.all(scaleConfig.scale(5.0)),
              child: DropdownButton<int>(
                underline: const SizedBox(),
                value: incomeType,
                dropdownColor: cardColor,
                icon: Icon(Icons.stacked_line_chart_outlined,
                    color: AppColors.textColorDarkTheme,
                    size: scaleConfig.scale(20)),
                items: [
                  DropdownMenuItem<int>(
                      value: 0,
                      child: Icon(Icons.trending_down,
                          color: incomeType == 0
                              ? AppColors.accentColor
                              : Colors.white,
                          size: scaleConfig.scale(18))),
                  DropdownMenuItem<int>(
                      value: 1,
                      child: Icon(Icons.trending_up,
                          color: incomeType == 1
                              ? AppColors.accentColor
                              : Colors.white,
                          size: scaleConfig.scale(18))),
                  DropdownMenuItem<int>(
                      value: 2,
                      child: Icon(Icons.multiline_chart,
                          color: incomeType == 2
                              ? AppColors.accentColor
                              : Colors.white,
                          size: scaleConfig.scale(18))),
                ],
                onChanged: (value) => setState(() => incomeType = value ?? 0),
                selectedItemBuilder: (context) =>
                    const [SizedBox(), SizedBox(), SizedBox()],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: scaleConfig.scale(5),
                vertical: scaleConfig.scale(5)),
            child: DropdownButton<int>(
              underline: const SizedBox(),
              value: chartType,
              dropdownColor: cardColor,
              icon: Icon(Icons.analytics_outlined,
                  color: AppColors.textColorDarkTheme,
                  size: scaleConfig.scale(20)),
              items: [
                DropdownMenuItem<int>(
                    value: 0,
                    child: Icon(Icons.donut_large_outlined,
                        color: chartType == 0
                            ? AppColors.accentColor
                            : Colors.white,
                        size: scaleConfig.scale(18))),
                DropdownMenuItem<int>(
                    value: 1,
                    child: Icon(Icons.bar_chart_outlined,
                        color: chartType == 1
                            ? AppColors.accentColor
                            : Colors.white,
                        size: scaleConfig.scale(18))),
                if (!showDayTabs)
                  DropdownMenuItem<int>(
                      value: 2,
                      child: Icon(Icons.ssid_chart_outlined,
                          color: chartType == 2
                              ? AppColors.accentColor
                              : Colors.white,
                          size: scaleConfig.scale(18))),
              ],
              onChanged: (value) => setState(() => chartType = value!),
              selectedItemBuilder: (context) =>
                  const [SizedBox(), SizedBox(), SizedBox()],
            ),
          ),
          IconButton(
            key: _filterIconKey,
            icon: Icon(Icons.filter_list,
                size: scaleConfig.scale(20),
                color: AppColors.textColorDarkTheme),
            onPressed: () {
              final RenderBox? renderBox = _filterIconKey.currentContext
                  ?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final iconPosition = renderBox.localToGlobal(Offset.zero);
                final iconSize = renderBox.size;
                showMenu(
                  color: cardColor,
                  context: context,
                  position: RelativeRect.fromLTRB(
                      iconPosition.dx - 150,
                      iconPosition.dy + iconSize.height,
                      context.size!.width - iconPosition.dx,
                      context.size!.height - iconPosition.dy),
                  items: _buildMenuItems(context),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(calculateAppBarHeight(scaleConfig)),
          child: Column(
            children: [
              if (showYearTabs)
                TabBar(
                  labelColor: AppColors.textColorDarkTheme,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  indicatorColor: AppColors.accentColor,
                  controller: _yearTabController,
                  labelStyle: TextStyle(fontSize: scaleConfig.scaleText(11)),
                  tabs: List.generate(
                      6, (index) => Tab(text: (2022 + index).toString())),
                ),
              if (showMonthTabs)
                TabBar(
                  labelColor: AppColors.textColorDarkTheme,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  indicatorColor: AppColors.accentColor,
                  controller: _monthTabController,
                  labelStyle: TextStyle(fontSize: scaleConfig.scaleText(11)),
                  tabs: [
                    Tab(text: "Jan".tr),
                    Tab(text: "Feb".tr),
                    Tab(text: "Mar".tr),
                    Tab(text: "Apr".tr),
                    Tab(text: "May".tr),
                    Tab(text: "Jun".tr),
                    Tab(text: "Jul".tr),
                    Tab(text: "Aug".tr),
                    Tab(text: "Sep".tr),
                    Tab(text: "Oct".tr),
                    Tab(text: "Nov".tr),
                    Tab(text: "Dec".tr),
                  ],
                ),
              if (showDayTabs)
                TabBar(
                  labelColor: AppColors.textColorDarkTheme,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  indicatorColor: AppColors.accentColor,
                  controller: _dayTabController,
                  labelStyle: TextStyle(fontSize: scaleConfig.scaleText(11)),
                  tabs: List.generate(
                      getDaysInMonth(selectedMonth, selectedYear),
                      (index) => Tab(
                          text: isArabic
                              ? _convertToArabicNumerals((index + 1).toString())
                              : (index + 1).toString())),
                ),
            ],
          ),
        ),
      ),
      body: MonthView(
        currencyCode: currentDisplayCurrency.code,
        currencySymbol: currentDisplayCurrency.symbol,
        month: selectedMonth,
        year: selectedYear,
        day: selectedDay,
        isYear: showYearTabs,
        isMonth: showMonthTabs,
        isDay: showDayTabs,
        isIncome: incomeType,
        chartType: chartType,
        showIncomeThings: switchState,
      ),
    );
  }

  List<PopupMenuItem<dynamic>> _buildMenuItems(BuildContext context) {
    return [
      PopupMenuItem(
        child: CheckboxListTile(
          checkColor: AppColors.textColorDarkTheme,
          activeColor: AppColors.accentColor2,
          title: Text("Show Year".tr,
              style: TextStyle(
                  fontSize: context.scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme)),
          value: showYearTabs,
          onChanged: (value) => _updateCheckboxState(year: value),
        ),
      ),
      PopupMenuItem(
        child: CheckboxListTile(
          checkColor: AppColors.textColorDarkTheme,
          activeColor: AppColors.accentColor2,
          title: Text("Show Month".tr,
              style: TextStyle(
                  fontSize: context.scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme)),
          value: showMonthTabs,
          onChanged: (value) => _updateCheckboxState(month: value),
        ),
      ),
      PopupMenuItem(
        child: CheckboxListTile(
          checkColor: AppColors.textColorDarkTheme,
          activeColor: AppColors.accentColor2,
          title: Text("Show Day".tr,
              style: TextStyle(
                  fontSize: context.scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme)),
          value: showDayTabs,
          onChanged: showMonthTabs
              ? (value) => _updateCheckboxState(day: value)
              : null,
        ),
      ),
    ];
  }

  int getDaysInMonth(int month, int year) => DateTime(year, month + 1, 0).day;
  String _convertToArabicNumerals(String number) {
    const Map<String, String> numerals = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩'
    };
    return number.split('').map((char) => numerals[char] ?? char).join();
  }
}

class MonthView extends ConsumerWidget {
  final String currencyCode;
  final String currencySymbol;
  final int month;
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final int isIncome;
  final int chartType;
  final bool showIncomeThings;

  const MonthView({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
    required this.month,
    required this.year,
    required this.day,
    this.isYear = true,
    this.isMonth = true,
    this.isDay = true,
    required this.isIncome,
    required this.chartType,
    required this.showIncomeThings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context);

    // --- THE FIX: Get the current display currency here to pass to report pages ---
    final currentDisplayCurrency = ref.watch(currencyProvider).displayCurrency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: scaleConfig.scale(25)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleConfig.scale(21.5)),
          child: Center(
            child: ChartCard(
              currencyCode: currencyCode,
              currencySymbol: currencySymbol,
              month: month,
              year: year,
              day: day,
              isYear: isYear,
              isMonth: isMonth,
              isDay: isDay,
              isIncome: isIncome,
              chartType: chartType,
            ),
          ),
        ),
        SizedBox(height: scaleConfig.scale(10)),
        if ((isMonth && !isYear && !isDay) || (isMonth && isYear && !isDay))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: scaleConfig.isTablet
                    ? scaleConfig.widthPercentage(0.42)
                    : scaleConfig.scale(170),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(scaleConfig.scale(12))),
                    padding: EdgeInsets.symmetric(
                        vertical: scaleConfig.scale(12),
                        horizontal: scaleConfig.scale(16)),
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalendarViewPage(
                              month: month,
                              year: year,
                              showIncomes: isIncome != 0))),
                  child: Text('Calendar View'.tr,
                      style: TextStyle(
                          color: AppColors.textColorDarkTheme,
                          fontSize: scaleConfig.tabletScaleText(12))),
                ),
              ),
              if (showIncomeThings) SizedBox(width: scaleConfig.scale(10)),
              if (showIncomeThings)
                SizedBox(
                  width: scaleConfig.isTablet
                      ? scaleConfig.widthPercentage(0.42)
                      : scaleConfig.scale(170),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(scaleConfig.scale(12))),
                      padding: EdgeInsets.symmetric(
                          vertical: scaleConfig.scale(12),
                          horizontal: scaleConfig.scale(16)),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MonthlyTablePage(
                                  // --- THE FIX: Pass currency info ---
                                  currencyCode: currentDisplayCurrency.code,
                                  currencySymbol: currentDisplayCurrency.symbol,
                                  month: month,
                                  year: year,
                                ))),
                    child: Text('Report Table'.tr,
                        style: TextStyle(
                            color: AppColors.textColorDarkTheme,
                            fontSize: scaleConfig.tabletScaleText(12))),
                  ),
                ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIncomeThings)
                SizedBox(
                  width: scaleConfig.isTablet
                      ? scaleConfig.widthPercentage(0.9)
                      : scaleConfig.scale(340),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(scaleConfig.scale(12))),
                      padding: EdgeInsets.symmetric(
                          vertical: scaleConfig.scale(12),
                          horizontal: scaleConfig.scale(16)),
                    ),
                    onPressed: () {
                      if (isYear && !isMonth && !isDay) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YearlyTablePage(
                                      // --- THE FIX: Pass currency info ---
                                      currencyCode: currentDisplayCurrency.code,
                                      currencySymbol:
                                          currentDisplayCurrency.symbol,
                                      year: year,
                                    )));
                      } else if (isDay) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DayReportPage(
                                      // --- THE FIX: Pass currency info ---
                                      currencyCode: currentDisplayCurrency.code,
                                      currencySymbol:
                                          currentDisplayCurrency.symbol,
                                      month: month,
                                      year: year,
                                      day: day,
                                    )));
                      }
                    },
                    child: Text('Detailed Report Table'.tr,
                        style: TextStyle(
                            color: AppColors.textColorDarkTheme,
                            fontSize: scaleConfig.tabletScaleText(12))),
                  ),
                ),
            ],
          ),
        SizedBox(height: scaleConfig.scale(10)),
        isIncome == 2
            ? Expanded(
                child: IncomeExpenseCategoryList(
                  currencyCode: currencyCode,
                  month: month,
                  year: year,
                  day: day,
                  isYear: isYear,
                  isMonth: isMonth,
                  isDay: isDay,
                ),
              )
            : Expanded(
                child: CategoryList(
                  currencyCode: currencyCode,
                  month: month,
                  year: year,
                  day: day,
                  isYear: isYear,
                  isMonth: isMonth,
                  isDay: isDay,
                  isIncome: isIncome != 0,
                ),
              ),
      ],
    );
  }
}
