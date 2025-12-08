import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../models/transaction.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletProvider>();
      provider.loadWallet();
      provider.loadTransactions(refresh: true);
    });
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
        appBar: RotaxAppBar(
          title: 'Cüzdanım',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              onPressed: () {
                context.read<WalletProvider>().loadWallet();
                context.read<WalletProvider>().loadTransactions(refresh: true);
              },
            ),
          ],
        ),
        body: Consumer<WalletProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.wallet == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadWallet();
                await provider.loadTransactions(refresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    _buildBalanceCard(provider),
                    const SizedBox(height: 16),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: RotaxButton(
                            text: 'Para Yükle',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DepositScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RotaxButton(
                            text: 'Para Çek',
                            icon: Icons.remove,
                            isOutlined: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Toplam Kazanç',
                            '₺${provider.wallet?.totalEarnings.toStringAsFixed(2) ?? "0.00"}',
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            'Toplam Harcama',
                            '₺${provider.wallet?.totalSpent.toStringAsFixed(2) ?? "0.00"}',
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Transactions
                    const Text(
                      'İşlem Geçmişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionsList(provider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundDark, Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.wallet?.isActive == true
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.wallet?.isActive == true ? 'Aktif' : 'Pasif',
                  style: TextStyle(
                    color: provider.wallet?.isActive == true ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Mevcut Bakiye',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₺${provider.wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((provider.wallet?.frozenBalance ?? 0) > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'Bloke: ₺${provider.wallet?.frozenBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return RotaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(WalletProvider provider) {
    if (provider.transactions.isEmpty) {
      return RotaxCard(
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Henüz işlem yok',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: provider.transactions.map((transaction) {
        return _TransactionItem(transaction: transaction);
      }).toList(),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RotaxCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isIncome ? AppColors.success : AppColors.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(),
                color: isIncome ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.typeText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.description != null)
                    Text(
                      transaction.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isIncome ? AppColors.success : AppColors.error,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case TransactionType.DEPOSIT:
        return Icons.add_circle;
      case TransactionType.WITHDRAWAL:
        return Icons.remove_circle;
      case TransactionType.CARGO_PAYMENT:
        return Icons.local_shipping;
      case TransactionType.DRIVER_EARNING:
        return Icons.monetization_on;
      case TransactionType.COMMISSION:
        return Icons.percent;
      case TransactionType.REFUND:
        return Icons.replay;
      case TransactionType.BONUS:
        return Icons.card_giftcard;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.COMPLETED:
        return AppColors.success;
      case TransactionStatus.PENDING:
        return AppColors.warning;
      case TransactionStatus.FAILED:
      case TransactionStatus.CANCELLED:
        return AppColors.error;
      case TransactionStatus.REFUNDED:
        return AppColors.info;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }
}
