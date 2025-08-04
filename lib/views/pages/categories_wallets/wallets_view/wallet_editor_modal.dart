// lib/views/pages/categories_wallets/wallets_view/wallet_editor_modal.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/domain/models/wallet.dart'; // Make sure this path is correct
import 'package:budgify/core/themes/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletEditorModal extends ConsumerStatefulWidget {
  final Wallet? walletToUpdate;
  final Function(Wallet) onWalletSaved;
  final BuildContext pageContext;

  const WalletEditorModal({
    super.key,
    required this.onWalletSaved,
    required this.pageContext,
    this.walletToUpdate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _WalletEditorModalState createState() => _WalletEditorModalState();
}

class _WalletEditorModalState extends ConsumerState<WalletEditorModal> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  final _sliderMaxController = TextEditingController();

  late bool _isUpdating;
  Currency? _selectedCurrency;
  WalletType _selectedType = WalletType.cash;
  WalletFunctionality _functionality = WalletFunctionality.both;
  bool _isEnabled = true;
  bool _isTransferEnabled = true;
  bool _hasLimits = false;
  RangeValues _currentRangeValues = const RangeValues(0, 5000);
  double _sliderMax = 10000.0;

  @override
  void initState() {
    super.initState();
    _isUpdating = widget.walletToUpdate != null;

    if (_isUpdating) {
      final wallet = widget.walletToUpdate!;
      _walletNameController.text = wallet.name;

      _selectedCurrency = availableCurrencies.firstWhere(
        (c) => c.code == wallet.currencyCode,
        orElse: () => ref.read(currencyProvider).displayCurrency,
      );

      _selectedType = wallet.type;
      _functionality = wallet.allowedTransactionType;
      _isEnabled = wallet.isEnabled;
      _isTransferEnabled = wallet.isTransferEnabled;

      if (wallet.minValue != null || wallet.maxValue != null) {
        _hasLimits = true;
        final min = wallet.minValue ?? 0;
        final max = wallet.maxValue ?? 5000;
        _sliderMax = (max > 10000.0) ? max * 1.2 : 10000.0;
        _currentRangeValues = RangeValues(min, max);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isUpdating) {
      _selectedCurrency ??= ref.read(currencyProvider).displayCurrency;
    }
    _sliderMaxController.text = _sliderMax.toInt().toString();
  }

  void _saveWallet() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrency == null) {
      showFeedbackSnackbar(
        widget.pageContext,
        'Please select a currency'.tr,
        isError: true,
      );
      return;
    }

    final name = _walletNameController.text.trim();
    // These values are only used if _hasLimits is true
    final double? minValue = _hasLimits ? _currentRangeValues.start : null;
    final double? maxValue = _hasLimits ? _currentRangeValues.end : null;

    if (_isUpdating) {
      final originalWallet = widget.walletToUpdate!;

      // --- THIS IS THE FIX ---
      // We now wrap the nullable values in the `Optional` helper class.
      // This tells the updated `copyWith` method to explicitly set the
      // value, even if that value is `null`.
      final updatedWallet = originalWallet.copyWith(
        name: name,
        type: _selectedType,
        isEnabled: _isEnabled,
        allowedTransactionType: _functionality,
        isTransferEnabled: _isTransferEnabled,
        minValue: Optional(_hasLimits ? minValue : null), // Wrap in Optional
        maxValue: Optional(_hasLimits ? maxValue : null), // Wrap in Optional
      );
      // --- END OF FIX ---

      ref.read(walletProvider.notifier).updateWallet(updatedWallet);
      widget.onWalletSaved(updatedWallet);
      Navigator.of(context).pop();
      showFeedbackSnackbar(
        widget.pageContext,
        "'${updatedWallet.name}' wallet updated successfully".tr,
      );
    } else {
      final newWallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: _selectedType,
        currencyCode: _selectedCurrency!.code,
        currencySymbol: _selectedCurrency!.symbol,
        isEnabled: _isEnabled,
        allowedTransactionType: _functionality,
        isTransferEnabled: _isTransferEnabled,
        minValue: minValue, // No change needed for constructor
        maxValue: maxValue,
      );

      ref.read(walletProvider.notifier).addWallet(newWallet);
      widget.onWalletSaved(newWallet);
      Navigator.of(context).pop();
      showFeedbackSnackbar(
        widget.pageContext,
        "'${newWallet.name}' wallet added successfully".tr,
      );
    }
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _sliderMaxController.dispose();
    super.dispose();
  }

  void _showCurrencySearchDialog() async {
    if (_isUpdating) return;

    final result = await showDialog<Currency>(
      context: context,
      builder: (context) => const _CurrencySearchDialog(),
    );

    if (result != null) {
      setState(() => _selectedCurrency = result);
    }
  }

  Widget _buildSectionHeader(String title, ResponsiveUtil responsive) {
    return Padding(
      padding: EdgeInsets.only(
        top: responsive.setHeight(16),
        bottom: responsive.setHeight(8),
      ),
      child: Text(
        title.tr,
        style: TextStyle(
          color: AppColors.accentColor.withOpacity(0.8),
          fontSize: responsive.setSp(11),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final cardColor = Theme.of(context).appBarTheme.backgroundColor!;
    final int divisions = (_sliderMax / 100).round();
    final int safeDivisions = divisions > 0 ? divisions : 1;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.setWidth(20)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom + responsive.setHeight(16),
        left: responsive.setWidth(16),
        right: responsive.setWidth(16),
        top: responsive.setHeight(16),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isUpdating ? 'Update Wallet'.tr : 'Add New Wallet'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.setSp(16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              _buildSectionHeader('General'.tr, responsive),
              TextFormField(
                controller: _walletNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Wallet Name'.tr,
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: responsive.setWidth(18),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter a name'.tr : null,
              ),
              SizedBox(height: responsive.setHeight(18)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isUpdating ? null : _showCurrencySearchDialog,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Currency'.tr,
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: _isUpdating ? Colors.grey[600] : Colors.white,
                        size: responsive.setWidth(18),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    child: Text(
                      _selectedCurrency != null
                          ? '${_selectedCurrency!.code.tr} (${_selectedCurrency!.symbol})'
                          : 'Select Currency'.tr,
                      style: TextStyle(
                        color: _isUpdating ? Colors.grey[600] : Colors.white,
                        fontSize: responsive.setSp(12),
                      ),
                    ),
                  ),
                ),
              ),
              _buildSectionHeader('Limits'.tr, responsive),
              SwitchListTile(
                title: Text(
                  'Set Min/Max Limits'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.setSp(12),
                  ),
                ),
                value: _hasLimits,
                onChanged: (v) {
                  setState(() {
                    _hasLimits = v;
                    if (!v) {
                      _currentRangeValues = const RangeValues(0, 5000);
                      _sliderMax = 10000.0;
                      _sliderMaxController.text = _sliderMax.toInt().toString();
                    }
                  });
                },
                activeColor: AppColors.accentColor,
                contentPadding: EdgeInsets.zero,
              ),
              if (_hasLimits)
                Column(
                  children: [
                    TextFormField(
                      controller: _sliderMaxController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Set Maximum Range for Slider'.tr,
                        suffixText: _selectedCurrency?.code ?? '',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please set a max range'.tr;
                        }
                        if ((double.tryParse(value) ?? 0) <= 0) {
                          return 'Must be greater than 0'.tr;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final newMax = double.tryParse(value);
                        if (newMax != null && newMax > 0) {
                          setState(() {
                            _sliderMax = newMax;
                            _currentRangeValues = RangeValues(
                              _currentRangeValues.start.clamp(0, newMax),
                              _currentRangeValues.end.clamp(0, newMax),
                            );
                          });
                        }
                      },
                    ),
                    SizedBox(height: responsive.setHeight(10)),
                    RangeSlider(
                      values: _currentRangeValues,
                      max: _sliderMax,
                      divisions: safeDivisions,
                      activeColor: AppColors.accentColor,
                      inactiveColor: Colors.grey[700],
                      labels: RangeLabels(
                        NumberFormat.compact().format(
                          _currentRangeValues.start,
                        ),
                        NumberFormat.compact().format(_currentRangeValues.end),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() => _currentRangeValues = values);
                      },
                    ),
                  ],
                ),
              _buildSectionHeader('Functionality'.tr, responsive),
              DropdownButtonFormField<WalletType>(
                value: _selectedType,
                dropdownColor: cardColor,
                decoration: InputDecoration(
                  labelText: 'Wallet Type'.tr,
                  prefixIcon: Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: responsive.setWidth(18),
                  ),
                ),
                onChanged: (v) => setState(() => _selectedType = v!),
                items: WalletType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.capitalizeFirst.toString().tr),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: responsive.setHeight(18)),
              DropdownButtonFormField<WalletFunctionality>(
                value: _functionality,
                dropdownColor: cardColor,
                decoration: InputDecoration(
                  labelText: 'Allowed Transactions'.tr,
                  prefixIcon: Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: responsive.setWidth(18),
                  ),
                ),
                onChanged: (v) => setState(() => _functionality = v!),
                items: WalletFunctionality.values
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.name.capitalizeFirst.toString().tr),
                      ),
                    )
                    .toList(),
              ),
              SwitchListTile(
                title: Text(
                  'Enabled'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.setSp(12),
                  ),
                ),
                value: _isEnabled,
                onChanged: (v) => setState(() => _isEnabled = v),
                activeColor: AppColors.accentColor,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(
                  'Transfers Enabled'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.setSp(12),
                  ),
                ),
                value: _isTransferEnabled,
                onChanged: (v) => setState(() => _isTransferEnabled = v),
                activeColor: AppColors.accentColor,
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: responsive.setHeight(28)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.setHeight(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.setWidth(8)),
                  ),
                ),
                onPressed: _saveWallet,
                child: Text(
                  _isUpdating ? 'Update Wallet'.tr : 'Add Wallet'.tr,
                  style: TextStyle(
                    fontSize: responsive.setSp(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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

class _CurrencySearchDialog extends StatefulWidget {
  const _CurrencySearchDialog();

  @override
  State<_CurrencySearchDialog> createState() => _CurrencySearchDialogState();
}

class _CurrencySearchDialogState extends State<_CurrencySearchDialog> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies = availableCurrencies.where((currency) {
      final query = _searchQuery.toLowerCase();
      final translatedName = currency.code.tr.toLowerCase();
      return translatedName.contains(query) ||
          currency.code.toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text('Select Currency'.tr),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or code...'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = filteredCurrencies[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${currency.code.tr} (${currency.code})'),
                    trailing: Text(currency.symbol),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(currency);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr),
        ),
      ],
    );
  }
}
