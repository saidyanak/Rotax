import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import 'driver_offers_screen.dart';
import 'driver_profile_screen.dart';
import '../wallet/wallet_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DriverDashboardTab(),
    const DriverOffersScreen(),
    const WalletScreen(),
    const DriverProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDashboard();
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
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Teklifler'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Cüzdan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class DriverDashboardTab extends StatelessWidget {
  const DriverDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final driverProvider = context.watch<DriverProvider>();
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
          title: 'Merhaba, ${authProvider.user?.firstName ?? "Sürücü"}',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              onPressed: () {
                driverProvider.loadDashboard();
                walletProvider.loadWallet();
              },
            ),
          ],
        ),
        body: driverProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: () async {
                  await driverProvider.loadDashboard();
                  await walletProvider.loadWallet();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildStatusCard(context, driverProvider),
                      const SizedBox(height: 16),

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
                            title: 'Tamamlanan',
                            value: '${driverProvider.dashboard?['completedDeliveries'] ?? 0}',
                            icon: Icons.check_circle,
                            iconColor: AppColors.success,
                          ),
                          StatCard(
                            title: 'Aktif Kargo',
                            value: '${driverProvider.dashboard?['activeDeliveries'] ?? 0}',
                            icon: Icons.local_shipping,
                            iconColor: AppColors.warning,
                          ),
                          StatCard(
                            title: 'Puan',
                            value: '${driverProvider.dashboard?['rating']?.toStringAsFixed(1) ?? "0.0"}',
                            icon: Icons.star,
                            iconColor: Colors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Active Cargo Section
                      const Text(
                        'Aktif Kargolar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActiveCargosSection(driverProvider),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, DriverProvider provider) {
    final status = provider.currentStatus;
    final isOnline = status != 'OFFLINE';

    return RotaxCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (value) {
                  provider.updateStatus(
                    value ? 'ACTIVE' : 'OFFLINE',
                    41.0082, // TODO: Get actual location
                    28.9784,
                  );
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip('Aktif', status == 'ACTIVE', () {
                  provider.updateStatus('ACTIVE', 41.0082, 28.9784);
                }),
                const SizedBox(width: 8),
                _buildStatusChip('Hedefe Gidiyor', status == 'DESTINATION_BASED', () {
                  provider.updateStatus('DESTINATION_BASED', 41.0082, 28.9784);
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCargosSection(DriverProvider provider) {
    final activeCargos = provider.dashboard?['activeCargos'] as List? ?? [];

    if (activeCargos.isEmpty) {
      return RotaxCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 8),
              const Text(
                'Aktif kargo yok',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: activeCargos.map((cargo) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RotaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kargo #${cargo['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cargo['status'] ?? 'Aktif',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cargo['targetAddress'] ?? 'Adres bilgisi yok',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
