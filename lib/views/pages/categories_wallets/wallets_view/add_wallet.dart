import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:get/get.dart';
import '../../../../viewmodels/providers/wallet_provider.dart';

class AddWalletModal extends ConsumerStatefulWidget {
  final Function(Wallet) onWalletAdded;

  const AddWalletModal({super.key, required this.onWalletAdded});

  @override
  // ignore: library_private_types_in_public_api
  _AddWalletModalState createState() => _AddWalletModalState();
}

class _AddWalletModalState extends ConsumerState<AddWalletModal> {
  final TextEditingController _walletNameController = TextEditingController();
  WalletType _selectedType = WalletType.cash;
  final _formKey = GlobalKey<FormState>();

  void _addWallet() {
    if (_formKey.currentState!.validate()) {
      final name = _walletNameController.text.trim();
      final newWallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: _selectedType,
        isDefault: false,
      );

      ref.read(walletProvider.notifier).addWallet(newWallet);
      widget.onWalletAdded(newWallet);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleConfig = context.scaleConfig;
    final cardColor = context.appTheme.appBarTheme.backgroundColor!;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(scaleConfig.tabletScale(20)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            scaleConfig.tabletScale(16),
        left: scaleConfig.tabletScale(16),
        right: scaleConfig.tabletScale(16),
        top: scaleConfig.tabletScale(16),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Add New Wallet'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scaleConfig.tabletScaleText(16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: scaleConfig.tabletScale(14)),

              // Wallet Name Field
              TextFormField(
                controller: _walletNameController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scaleConfig.tabletScaleText(12),
                ),
                decoration: InputDecoration(
                  labelText: 'Wallet Name'.tr,
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: scaleConfig.tabletScaleText(12),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white54,
                      width: scaleConfig.tabletScale(1),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: scaleConfig.tabletScale(2),
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: scaleConfig.tabletScale(18),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a wallet name'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: scaleConfig.tabletScale(18)),

              // Wallet Type Dropdown
              DropdownButtonFormField<WalletType>(
                value: _selectedType,
                dropdownColor: cardColor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scaleConfig.tabletScaleText(12),
                ),
                decoration: InputDecoration(
                  labelText: 'Wallet Type'.tr,
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: scaleConfig.tabletScaleText(12),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white54,
                      width: scaleConfig.tabletScale(1),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: scaleConfig.tabletScale(2),
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: scaleConfig.tabletScale(18),
                  ),
                ),
                onChanged: (WalletType? newValue) {
                  setState(() => _selectedType = newValue!);
                },
                items:
                    WalletType.values.map((WalletType type) {
                      return DropdownMenuItem<WalletType>(
                        value: type,
                        child: Text(
                          type.toString() == "WalletType.digital"
                              ? "Digital".tr
                              : type.toString() == "WalletType.cash"
                              ? "Cash".tr
                              : "Bank".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: scaleConfig.tabletScaleText(12),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: scaleConfig.tabletScale(28)),

              // Add Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    vertical: scaleConfig.tabletScale(
                      10,
                    ), // Reduced from 16 to 12
                    horizontal: scaleConfig.tabletScale(
                      10,
                    ), // Reduced from 16 to 12
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      scaleConfig.tabletScale(8),
                    ), // Reduced from 12 to 8
                  ),
                ),
                onPressed: _addWallet,
                child: Text(
                  'Add wallet'.tr,
                  style: TextStyle(
                    fontSize: scaleConfig.tabletScaleText(
                      12,
                    ), // Reduced from 16 to 14
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: scaleConfig.tabletScale(9)),
            ],
          ),
        ),
      ),
    );
  }
}
