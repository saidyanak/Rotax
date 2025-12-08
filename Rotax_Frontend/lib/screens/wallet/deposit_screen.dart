import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'CREDIT_CARD';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'CREDIT_CARD', 'label': 'Kredi Kartı', 'icon': Icons.credit_card},
    {'value': 'BANK_TRANSFER', 'label': 'Havale/EFT', 'icon': Icons.account_balance},
  ];

  final List<int> _quickAmounts = [50, 100, 250, 500, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _deposit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir tutar girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<WalletProvider>();
    final success = await provider.deposit(amount, _selectedMethod);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Para yükleme başarılı!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Bir hata oluştu'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_4.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const RotaxAppBar(title: 'Para Yükle', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Input
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yüklenecek Tutar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RotaxTextField(
                        hint: '0.00',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_lira,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Tutar gerekli';
                          final amount = double.tryParse(v!);
                          if (amount == null || amount <= 0) return 'Geçerli tutar girin';
                          if (amount < 10) return 'Minimum 10 TL';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quick Amount Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickAmounts.map((amount) {
                          return GestureDetector(
                            onTap: () => _amountController.text = amount.toString(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                              ),
                              child: Text(
                                '₺$amount',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Method
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ödeme Yöntemi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_paymentMethods.length, (index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedMethod == method['value'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedMethod = method['value']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    method['icon'],
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      method['label'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Minimum yükleme tutarı 10 TL\'dir.',
                          style: TextStyle(
                            color: AppColors.info.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Consumer<WalletProvider>(
                  builder: (context, provider, _) {
                    return RotaxButton(
                      text: 'Para Yükle',
                      icon: Icons.add,
                      isLoading: provider.isLoading,
                      width: double.infinity,
                      onPressed: _deposit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
