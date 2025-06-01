// import 'package:budgify/widgets/ads/reward_ads.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/category.dart';
import '../../../../data/repo/category_repositry.dart';

// Extension for Theme and ScaleConfig
extension ThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get appTextTheme => Theme.of(this).textTheme;
  ScaleConfig get scaleConfig => ScaleConfig(this);
}

// ScaleConfig class for responsive design
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
    // ignore: deprecated_member_use
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
}

class AddCategoryModal extends ConsumerStatefulWidget {
  final CategoryRepository categoryRepository;
  final Function(Category) onCategoryAdded;

  const AddCategoryModal({
    super.key,
    required this.categoryRepository,
    required this.onCategoryAdded,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddCategoryModalState createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends ConsumerState<AddCategoryModal> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedIconKey = 'category';
  Color _selectedColor = AppColors.accentColor2;
  CategoryType _selectedType = CategoryType.expense;
  final _formKey = GlobalKey<FormState>();

  // final RewardedAdManager _adManager = RewardedAdManager();

  // @override
  // void initState() {
  //   super.initState();
  //   _adManager.loadAd();
  // }

  void _pickColor(BuildContext context) async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        final scaleConfig = context.scaleConfig;
        return AlertDialog(
          backgroundColor: context.appTheme.appBarTheme.backgroundColor,
          title: Text(
            'Pick a color'.tr,
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: scaleConfig.tabletScaleText(14),
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleConfig.tabletScale(28),
                    vertical: scaleConfig.tabletScale(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(6),
                    ),
                  ),
                ),
                child: Text(
                  'Select'.tr,
                  style: TextStyle(
                    fontSize: scaleConfig.tabletScaleText(12),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(tempColor);
                },
              ),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _selectedColor = pickedColor;
      });
    }
  }

  void _pickIcon() {
    final scaleConfig = context.scaleConfig;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.appTheme.appBarTheme.backgroundColor,
          title: Text(
            'Pick an icon'.tr,
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: scaleConfig.tabletScaleText(14),
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: scaleConfig.tabletScale(300),
            child: GridView.count(
              crossAxisCount: 4,
              padding: EdgeInsets.all(scaleConfig.tabletScale(8)),
              crossAxisSpacing: scaleConfig.tabletScale(8),
              mainAxisSpacing: scaleConfig.tabletScale(8),
              children: [
                _buildIconButton('school', Icons.school),
                _buildIconButton('pets', Icons.pets),
                _buildIconButton('home', Icons.home),
                _buildIconButton('fitness_center', Icons.fitness_center),
                _buildIconButton('sports', Icons.sports),
                _buildIconButton('checkroom', Icons.checkroom),
                _buildIconButton('cable', Icons.cable),
                _buildIconButton('local_gas_station', Icons.local_gas_station),
                _buildIconButton('monitor_heart', Icons.monitor_heart),
                _buildIconButton('directions_car', Icons.directions_car),
                _buildIconButton('medication', Icons.medication),
                _buildIconButton('key', Icons.key),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleConfig.tabletScale(28),
                    vertical: scaleConfig.tabletScale(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(6),
                    ),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(
                    fontSize: scaleConfig.tabletScaleText(10),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(String iconKey, IconData icon) {
    final scaleConfig = context.scaleConfig;
    return IconButton(
      icon: Icon(
        icon,
        color: AppColors.accentColor,
        size: scaleConfig.tabletScale(24),
      ),
      onPressed: () {
        setState(() {
          _selectedIconKey = iconKey;
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _addCategory() {
    if (_formKey.currentState!.validate()) {
      final name = _categoryNameController.text.trim();
      final description = _descriptionController.text.trim();

      final existingCategories = widget.categoryRepository.loadCategories();
      if (existingCategories.any(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      )) {
        showFeedbackSnackbar(context, 'Category "$name" already exists'.tr);

        return;
      }

      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description.isNotEmpty ? description : null,
        iconKey: _selectedIconKey,
        color: _selectedColor,
        isNew: true,
        type: _selectedType,
      );

      widget.categoryRepository.addCategory(newCategory);
      widget.onCategoryAdded(newCategory);

      _categoryNameController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop();

      showFeedbackSnackbar(context, "Category added successfully!".tr);
      // _adManager.showAd(
      //   onUserEarnedReward: (RewardItem reward) {
      //     debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      //   },
      // );
    }
  }

  @override
  void dispose() {
    // _adManager.dispose();
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleConfig = context.scaleConfig;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            scaleConfig.tabletScale(16),
        left: scaleConfig.tabletScale(16),
        right: scaleConfig.tabletScale(16),
        top: scaleConfig.tabletScale(16),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Name TextField
              TextFormField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  labelText: 'Category Name'.tr,
                  labelStyle: TextStyle(
                    color: AppColors.accentColor,
                    fontSize: scaleConfig.tabletScaleText(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(8),
                    ),
                  ),
                ),
                style: TextStyle(fontSize: scaleConfig.tabletScaleText(16)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: scaleConfig.tabletScale(14)),

              // Description TextField (uncomment if needed)
              // TextFormField(
              //   controller: _descriptionController,
              //   decoration: InputDecoration(
              //     labelText: 'Description (optional)'.tr,
              //     labelStyle: TextStyle(
              //       color: AppColors.accentColor,
              //       fontSize: scaleConfig.tabletScaleText(16),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide:
              //           BorderSide(color: AppColors.accentColor, width: 1),
              //       borderRadius:
              //           BorderRadius.circular(scaleConfig.tabletScale(8)),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide:
              //           BorderSide(color: AppColors.accentColor, width: 2),
              //       borderRadius:
              //           BorderRadius.circular(scaleConfig.tabletScale(8)),
              //     ),
              //   ),
              //   style: TextStyle(fontSize: scaleConfig.tabletScaleText(16)),
              // ),
              // SizedBox(height: scaleConfig.tabletScale(16)),

              // Category Type Dropdown
              DropdownButtonFormField<CategoryType>(
                value: _selectedType,
                dropdownColor: context.appTheme.appBarTheme.backgroundColor,
                decoration: InputDecoration(
                  labelText: 'Category Type'.tr,
                  labelStyle: TextStyle(
                    color: AppColors.accentColor,
                    fontSize: scaleConfig.tabletScaleText(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(8),
                    ),
                  ),
                ),
                items:
                    CategoryType.values.map((CategoryType type) {
                      return DropdownMenuItem<CategoryType>(
                        value: type,
                        child: Text(
                          type == CategoryType.income
                              ? 'Income'.tr
                              : 'Expense'.tr,
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: scaleConfig.tabletScaleText(10),
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (CategoryType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              SizedBox(height: scaleConfig.tabletScale(14)),

              // Row with Color Picker and Icon Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _pickColor(context),
                    child: CircleAvatar(
                      radius: scaleConfig.tabletScale(24),
                      backgroundColor: _selectedColor,
                      child: Icon(
                        Icons.color_lens,
                        color: Colors.white,
                        size: scaleConfig.tabletScale(22),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickIcon,
                    child: CircleAvatar(
                      radius: scaleConfig.tabletScale(24),
                      backgroundColor: AppColors.accentColor2,
                      child: Icon(
                        Category.iconMap[_selectedIconKey] ?? Icons.category,
                        color: Colors.white,
                        size: scaleConfig.tabletScale(22),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: scaleConfig.tabletScale(22)),

              // Add Category Button
              Center(
                child: ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleConfig.tabletScale(10),
                      vertical: scaleConfig.tabletScale(10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        scaleConfig.tabletScale(6),
                      ),
                    ),
                  ),
                  child: Text(
                    'Add Category'.tr,
                    style: TextStyle(
                      fontSize: scaleConfig.tabletScaleText(12),
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
