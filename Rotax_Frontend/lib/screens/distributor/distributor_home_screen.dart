import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/distributor_provider.dart';
import '../../providers/wallet_provider.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DistributorDashboardTab(),
          DistributorCargosScreen(),
          WalletScreen(),
          DistributorProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.dark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Ana Sayfa'),
                _buildNavItem(1, Icons.inventory_2_rounded, 'Kargolar'),
                _buildNavItem(2, Icons.account_balance_wallet_rounded, 'Cüzdan'),
                _buildNavItem(3, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCargoScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Yeni Kargo', style: TextStyle(color: Colors.white)),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.white54, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributorDashboardTab extends StatelessWidget {
  const _DistributorDashboardTab();

  Future<void> _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final distributorProvider = context.watch<DistributorProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          await distributorProvider.loadDashboard();
          await walletProvider.loadWallet();
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.dark,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.dark, AppColors.info.withOpacity(0.8)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.info,
                                  child: Text(
                                    authProvider.user?.firstName?.substring(0, 1).toUpperCase() ?? 'D',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Merhaba, ${authProvider.user?.firstName ?? "Dağıtıcı"} 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Dağıtıcı',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white70),
                                onPressed: () => _logout(context),
                                tooltip: 'Çıkış Yap',
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Balance & Quick Stats
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                                          SizedBox(width: 8),
                                          Text('Bakiye', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₺${walletProvider.wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.local_shipping, color: Colors.white70, size: 20),
                                          SizedBox(width: 8),
                                          Text('Aktif', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${distributorProvider.dashboard?['activeCargos'] ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    distributorProvider.loadDashboard();
                    walletProvider.loadWallet();
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Card
                    _buildQuickActionCard(context),
                    const SizedBox(height: 24),

                    // Stats
                    const Text(
                      'Kargo İstatistikleri',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(distributorProvider),
                    const SizedBox(height: 24),

                    // Recent Activity
                    const Text(
                      'Son Aktiviteler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentCargos(distributorProvider),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yeni Kargo Oluştur',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hızlıca yeni bir gönderi oluşturun',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCargoScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DistributorProvider provider) {
    final dashboard = provider.dashboard;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Toplam Kargo', '${dashboard?['totalCargos'] ?? 0}', Icons.inventory_2_rounded, AppColors.info),
        _buildStatCard('Teslim Edildi', '${dashboard?['deliveredCargos'] ?? 0}', Icons.check_circle_rounded, AppColors.success),
        _buildStatCard('Devam Eden', '${dashboard?['activeCargos'] ?? 0}', Icons.local_shipping_rounded, AppColors.warning),
        _buildStatCard('İptal Edilen', '${dashboard?['cancelledCargos'] ?? 0}', Icons.cancel_rounded, AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildRecentCargos(DistributorProvider provider) {
    final recentCargos = provider.dashboard?['recentCargos'] as List? ?? [];

    if (recentCargos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceColor, shape: BoxShape.circle),
                child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              const Text('Henüz kargo yok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('İlk kargonuzu oluşturmak için + butonuna tıklayın', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentCargos.take(5).map((cargo) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(cargo['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_shipping, color: _getStatusColor(cargo['status'])),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cargo['trackingCode'] ?? 'Kargo #${cargo['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cargo['targetAddress'] ?? 'Hedef belirtilmemiş',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(cargo['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(cargo['status']),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(cargo['status']),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.success;
      case 'IN_TRANSIT':
      case 'PICKED_UP':
        return AppColors.warning;
      case 'CANCELLED':
        return AppColors.error;
      case 'PENDING':
      case 'WAITING_FOR_DRIVER':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'DELIVERED':
        return 'Teslim Edildi';
      case 'IN_TRANSIT':
        return 'Yolda';
      case 'PICKED_UP':
        return 'Alındı';
      case 'CANCELLED':
        return 'İptal';
      case 'PENDING':
        return 'Bekliyor';
      case 'WAITING_FOR_DRIVER':
        return 'Sürücü Bekleniyor';
      default:
        return status ?? 'Bilinmiyor';
    }
  }
}
