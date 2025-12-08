import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/distributor_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import 'distributor_cargos_screen.dart';
import 'create_cargo_screen.dart';
import '../wallet/wallet_screen.dart';
import 'distributor_profile_screen.dart';

class DistributorHomeScreen extends StatefulWidget {
  const DistributorHomeScreen({super.key});

  @override
  State<DistributorHomeScreen> createState() => _DistributorHomeScreenState();
}

class _DistributorHomeScreenState extends State<DistributorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DistributorDashboardTab(),
    const DistributorCargosScreen(),
    const WalletScreen(),
    const DistributorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistributorProvider>().loadDashboard();
      context.read<WalletProvider>().loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Kargolar'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Cüzdan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCargoScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Kargo'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

class DistributorDashboardTab extends StatelessWidget {
  const DistributorDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final distributorProvider = context.watch<DistributorProvider>();
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
        appBar: RotaxAppBar(
          title: 'Merhaba, ${authProvider.user?.firstName ?? "Dağıtıcı"}',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              onPressed: () {
                distributorProvider.loadDashboard();
                walletProvider.loadWallet();
              },
            ),
          ],
        ),
        body: distributorProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: () async {
                  await distributorProvider.loadDashboard();
                  await walletProvider.loadWallet();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      RotaxCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateCargoScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_box, color: AppColors.primary, size: 32),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yeni Kargo Oluştur',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Hemen yeni bir kargo gönderisi oluşturun',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          StatCard(
                            title: 'Bakiye',
                            value: '₺${walletProvider.wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
                            icon: Icons.account_balance_wallet,
                            iconColor: AppColors.success,
                          ),
                          StatCard(
                            title: 'Toplam Kargo',
                            value: '${distributorProvider.dashboard?['totalCargos'] ?? 0}',
                            icon: Icons.inventory_2,
                            iconColor: AppColors.info,
                          ),
                          StatCard(
                            title: 'Teslim Edildi',
                            value: '${distributorProvider.dashboard?['deliveredCargos'] ?? 0}',
                            icon: Icons.check_circle,
                            iconColor: AppColors.success,
                          ),
                          StatCard(
                            title: 'Devam Eden',
                            value: '${distributorProvider.dashboard?['activeCargos'] ?? 0}',
                            icon: Icons.local_shipping,
                            iconColor: AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Cargos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Son Kargolar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to cargos tab
                            },
                            child: const Text('Tümünü Gör'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRecentCargos(distributorProvider),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecentCargos(DistributorProvider provider) {
    final recentCargos = provider.dashboard?['recentCargos'] as List? ?? [];

    if (recentCargos.isEmpty) {
      return RotaxCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 8),
              const Text(
                'Henüz kargo yok',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentCargos.take(3).map((cargo) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RotaxCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kargo #${cargo['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cargo['targetAddress'] ?? 'Adres bilgisi yok',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(cargo['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(cargo['status']),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(cargo['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.success;
      case 'PICKED_UP':
      case 'ASSIGNED':
        return AppColors.warning;
      case 'CANCELLED':
      case 'FAILED':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'CREATED':
        return 'Oluşturuldu';
      case 'ASSIGNED':
        return 'Atandı';
      case 'PICKED_UP':
        return 'Alındı';
      case 'DELIVERED':
        return 'Teslim Edildi';
      case 'CANCELLED':
        return 'İptal';
      default:
        return status ?? 'Bilinmiyor';
    }
  }
}
