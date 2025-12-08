import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/distributor_service.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/cargo_status_badge.dart';
import '../../models/cargo.dart';

class CargoDetailScreen extends StatefulWidget {
  final int cargoId;

  const CargoDetailScreen({super.key, required this.cargoId});

  @override
  State<CargoDetailScreen> createState() => _CargoDetailScreenState();
}

class _CargoDetailScreenState extends State<CargoDetailScreen> {
  Cargo? _cargo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCargo();
  }

  Future<void> _loadCargo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cargo = await DistributorService.getCargoDetail(widget.cargoId);
      setState(() {
        _cargo = cargo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
        appBar: RotaxAppBar(
          title: 'Kargo #${widget.cargoId}',
          showBackButton: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: AppColors.textWhite)),
                        const SizedBox(height: 16),
                        RotaxButton(text: 'Tekrar Dene', onPressed: _loadCargo),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        RotaxCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kargo #${_cargo!.id}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    CargoStatusBadge(status: _cargo!.status),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        if (_cargo!.description != null) ...[
                          RotaxCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.description, size: 20, color: AppColors.textSecondary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Açıklama',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(_cargo!.description!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Locations
                        RotaxCard(
                          child: Column(
                            children: [
                              _buildLocationSection(
                                'Alış Noktası',
                                _cargo!.selfLocation?.fullAddress ?? 'Belirtilmemiş',
                                Icons.circle,
                                AppColors.success,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                              _buildLocationSection(
                                'Teslimat Noktası',
                                _cargo!.targetLocation?.fullAddress ?? 'Belirtilmemiş',
                                Icons.location_on,
                                AppColors.error,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Package Details
                        if (_cargo!.measure != null)
                          RotaxCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.straighten, size: 20, color: AppColors.textSecondary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Paket Bilgileri',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildMeasureItem('Boyut', _cargo!.measure!.size ?? '-'),
                                    _buildMeasureItem('Ağırlık', '${_cargo!.measure!.weight ?? '-'} kg'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildMeasureItem('Uzunluk', '${_cargo!.measure!.length ?? '-'} cm'),
                                    _buildMeasureItem('Genişlik', '${_cargo!.measure!.width ?? '-'} cm'),
                                    _buildMeasureItem('Yükseklik', '${_cargo!.measure!.height ?? '-'} cm'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Driver Info
                        if (_cargo!.driverName != null)
                          RotaxCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sürücü',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _cargo!.driverName!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.phone, color: AppColors.primary),
                                  onPressed: () {
                                    // TODO: Call driver
                                  },
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Verification Code
                        if (_cargo!.verificationCode != null)
                          RotaxCard(
                            child: Column(
                              children: [
                                const Icon(Icons.qr_code, size: 48, color: AppColors.primary),
                                const SizedBox(height: 8),
                                const Text(
                                  'Doğrulama Kodu',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _cargo!.verificationCode!,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Cancel Button
                        if (_cargo!.isActive)
                          RotaxButton(
                            text: 'Kargoyu İptal Et',
                            icon: Icons.cancel,
                            backgroundColor: AppColors.error,
                            width: double.infinity,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Kargoyu İptal Et'),
                                  content: const Text('Bu kargoyu iptal etmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Vazgeç'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('İptal Et', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await DistributorService.cancelCargo(_cargo!.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kargo iptal edildi'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Hata: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildLocationSection(String label, String address, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
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
                address,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureItem(String label, String value) {
    return Expanded(
      child: Column(
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
