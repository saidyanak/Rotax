import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/wallet_provider.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DriverDashboardTab(),
          DriverOffersScreen(),
          WalletScreen(),
          DriverProfileScreen(),
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
                _buildNavItem(1, Icons.local_offer_rounded, 'Teklifler'),
                _buildNavItem(2, Icons.account_balance_wallet_rounded, 'Cüzdan'),
                _buildNavItem(3, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
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
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white54,
              size: 24,
            ),
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

class _DriverDashboardTab extends StatefulWidget {
  const _DriverDashboardTab();

  @override
  State<_DriverDashboardTab> createState() => _DriverDashboardTabState();
}

class _DriverDashboardTabState extends State<_DriverDashboardTab> {
  double _latitude = 41.0082;
  double _longitude = 28.9784;
  final TextEditingController _latController = TextEditingController(text: '41.0082');
  final TextEditingController _lngController = TextEditingController(text: '28.9784');
  
  // Hedef lokasyon için
  final TextEditingController _destLatController = TextEditingController();
  final TextEditingController _destLngController = TextEditingController();
  double _maxDeviationKm = 5.0;

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  void _showDestinationDialog(DriverProvider provider) {
    _destLatController.text = provider.destinationLat?.toString() ?? '';
    _destLngController.text = provider.destinationLng?.toString() ?? '';
    _maxDeviationKm = provider.maxDeviationKm;
    
    String? selectedCity = provider.destinationCity;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.flag, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Hedef Lokasyon', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nereye gidiyorsunuz? Sadece rotanız üzerindeki kargolar gösterilecek.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text('Hızlı Seçim', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDestinationChip('İstanbul', 41.0082, 28.9784, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                    _buildDestinationChip('Ankara', 39.9334, 32.8597, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                    _buildDestinationChip('İzmir', 38.4237, 27.1428, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                    _buildDestinationChip('Bursa', 40.1885, 29.0610, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                    _buildDestinationChip('Antalya', 36.8969, 30.7133, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                    _buildDestinationChip('Konya', 37.8746, 32.4932, selectedCity, (name, lat, lng) {
                      setDialogState(() => selectedCity = name);
                      _destLatController.text = lat.toString();
                      _destLngController.text = lng.toString();
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _destLatController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Hedef Enlem',
                    prefixIcon: const Icon(Icons.north, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destLngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Hedef Boylam',
                    prefixIcon: const Icon(Icons.east, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Maksimum Sapma', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Rotanızdan ne kadar uzaktaki kargolar gösterilsin?',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _maxDeviationKm,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '${_maxDeviationKm.toInt()} km',
                        onChanged: (value) {
                          setDialogState(() => _maxDeviationKm = value);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_maxDeviationKm.toInt()} km',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final destLat = double.tryParse(_destLatController.text);
                final destLng = double.tryParse(_destLngController.text);
                
                if (destLat == null || destLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen geçerli koordinatlar girin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                provider.updateStatus(
                  'DESTINATION_BASED',
                  _latitude,
                  _longitude,
                  destLat: destLat,
                  destLng: destLng,
                  destCity: selectedCity,
                  maxDeviation: _maxDeviationKm,
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Hedefe Git'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDestinationChip(String name, double lat, double lng, String? selected, Function(String, double, double) onSelect) {
    final isSelected = selected == name;
    return ChoiceChip(
      label: Text(name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
      selected: isSelected,
      onSelected: (_) => onSelect(name, lat, lng),
      backgroundColor: AppColors.surfaceColor,
      selectedColor: AppColors.primary,
    );
  }

  void _showLocationDialog() {
    _latController.text = _latitude.toString();
    _lngController.text = _longitude.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Konum Belirle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enlem (Latitude)',
                prefixIcon: const Icon(Icons.north),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lngController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Boylam (Longitude)',
                prefixIcon: const Icon(Icons.east),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickLocation('İstanbul', 41.0082, 28.9784),
                _buildQuickLocation('Ankara', 39.9334, 32.8597),
                _buildQuickLocation('İzmir', 38.4237, 27.1428),
                _buildQuickLocation('Bursa', 40.1885, 29.0610),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _latitude = double.tryParse(_latController.text) ?? _latitude;
                _longitude = double.tryParse(_lngController.text) ?? _longitude;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Konum güncellendi: $_latitude, $_longitude'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLocation(String name, double lat, double lng) {
    return ActionChip(
      label: Text(name, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _latController.text = lat.toString();
        _lngController.text = lng.toString();
      },
      backgroundColor: AppColors.surfaceColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final driverProvider = context.watch<DriverProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          await driverProvider.loadDashboard();
          await walletProvider.loadWallet();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
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
                      colors: [AppColors.dark, AppColors.primary.withOpacity(0.8)],
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
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  authProvider.user?.firstName?.substring(0, 1).toUpperCase() ?? 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Merhaba, ${authProvider.user?.firstName ?? "Sürücü"} 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authProvider.user?.email ?? '',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white70),
                                onPressed: _logout,
                                tooltip: 'Çıkış Yap',
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bakiye',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    Text(
                                      '₺${walletProvider.wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                    driverProvider.loadDashboard();
                    walletProvider.loadWallet();
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(driverProvider),
                    const SizedBox(height: 20),
                    _buildLocationCard(),
                    const SizedBox(height: 20),
                    const Text(
                      'İstatistikler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(driverProvider),
                    const SizedBox(height: 24),
                    const Text(
                      'Aktif Kargolar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActiveCargos(driverProvider),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(DriverProvider provider) {
    final status = provider.currentStatus;
    final isOnline = status != 'OFFLINE';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? AppColors.success : AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                    Text(
                      isOnline ? 'Yeni teklifler alabilirsiniz' : 'Teklif almak için çevrimiçi olun',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: isOnline,
                  onChanged: provider.isLoading ? null : (value) {
                    provider.updateStatus(
                      value ? 'ACTIVE' : 'OFFLINE',
                      _latitude,
                      _longitude,
                    );
                  },
                  activeColor: AppColors.success,
                  activeTrackColor: AppColors.success.withOpacity(0.3),
                ),
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusOption(
                    'Aktif',
                    'Yakındaki tüm teklifler',
                    Icons.near_me,
                    status == 'ACTIVE',
                    () => provider.updateStatus('ACTIVE', _latitude, _longitude),
                    provider.isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusOption(
                    'Hedefe Gidiyor',
                    'Sadece rota üzeri',
                    Icons.route,
                    status == 'DESTINATION_BASED',
                    () => _showDestinationDialog(provider),
                    provider.isLoading,
                  ),
                ),
              ],
            ),
            // Hedef bilgisi göster
            if (status == 'DESTINATION_BASED' && provider.destinationCity != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hedef: ${provider.destinationCity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
                          ),
                          Text(
                            'Sapma: ${provider.maxDeviationKm.toInt()} km',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: AppColors.info),
                      onPressed: () => _showDestinationDialog(provider),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusOption(String title, String subtitle, IconData icon, bool isSelected, VoidCallback onTap, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mevcut Konum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('$_latitude, $_longitude', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showLocationDialog,
            icon: const Icon(Icons.edit_location_alt, size: 18),
            label: const Text('Değiştir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DriverProvider provider) {
    final dashboard = provider.dashboard;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Tamamlanan', '${dashboard?['completedDeliveries'] ?? 0}', Icons.check_circle_rounded, AppColors.success),
        _buildStatCard('Aktif Kargo', '${dashboard?['activeDeliveries'] ?? 0}', Icons.local_shipping_rounded, AppColors.warning),
        _buildStatCard('Toplam Kazanç', '₺${dashboard?['totalEarnings']?.toStringAsFixed(0) ?? 0}', Icons.payments_rounded, AppColors.info),
        _buildStatCard('Puan', '${dashboard?['rating']?.toStringAsFixed(1) ?? "0.0"} ⭐', Icons.star_rounded, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActiveCargos(DriverProvider provider) {
    final activeCargos = provider.dashboard?['activeCargos'] as List? ?? [];

    if (activeCargos.isEmpty) {
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
                child: Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              const Text('Aktif kargo yok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('Teklifler sekmesinden yeni kargo alabilirsiniz', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: activeCargos.map((cargo) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_shipping, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kargo #${cargo['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(cargo['trackingCode'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(cargo['status'] ?? 'Aktif', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cargo['targetAddress'] ?? 'Adres bilgisi yok', style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return RotaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
