import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _ibanController = TextEditingController();
  final _nameSurnameController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _ibanController.dispose();
    _nameSurnameController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<WalletProvider>();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount > (provider.wallet?.availableBalance ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetersiz bakiye'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final bankAccount = '${_ibanController.text} - ${_nameSurnameController.text}';
    final success = await provider.withdraw(amount, bankAccount);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çekim talebi oluşturuldu!'),
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
    final walletProvider = context.watch<WalletProvider>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_4.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const RotaxAppBar(title: 'Para Çek', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Info
                RotaxCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Çekilebilir Bakiye',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₺${walletProvider.wallet?.availableBalance.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Input
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çekilecek Tutar',
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
                          if (amount < 50) return 'Minimum 50 TL';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _amountController.text =
                              (walletProvider.wallet?.availableBalance ?? 0).toStringAsFixed(2);
                        },
                        child: const Text('Tamamını Çek'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bank Account
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Banka Hesap Bilgileri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RotaxTextField(
                        hint: 'IBAN (TR...)',
                        controller: _ibanController,
                        prefixIcon: Icons.account_balance,
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'IBAN gerekli';
                          if (!v!.startsWith('TR') || v.length < 26) return 'Geçerli IBAN girin';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      RotaxTextField(
                        hint: 'Hesap Sahibi Ad Soyad',
                        controller: _nameSurnameController,
                        prefixIcon: Icons.person,
                        validator: (v) => v?.isEmpty == true ? 'Ad soyad gerekli' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Çekim talepleri 1-3 iş günü içinde işleme alınır.',
                          style: TextStyle(
                            color: AppColors.warning.withOpacity(0.9),
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
                      text: 'Çekim Talebi Oluştur',
                      icon: Icons.send,
                      isLoading: provider.isLoading,
                      width: double.infinity,
                      onPressed: _withdraw,
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
