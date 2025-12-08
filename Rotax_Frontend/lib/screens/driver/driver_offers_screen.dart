import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/cargo_status_badge.dart';
import '../../models/cargo.dart';

class DriverOffersScreen extends StatefulWidget {
  const DriverOffersScreen({super.key});

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadOffers();
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
          title: 'Kargo Teklifleri',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              onPressed: () => context.read<DriverProvider>().loadOffers(),
            ),
          ],
        ),
        body: Consumer<DriverProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 80,
                      color: AppColors.textWhite.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz teklif yok',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni teklifler geldiğinde burada görünecek',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadOffers(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.offers.length,
                itemBuilder: (context, index) {
                  return _OfferCard(
                    cargo: provider.offers[index],
                    onAccept: () => _acceptOffer(provider, provider.offers[index].id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _acceptOffer(DriverProvider provider, int cargoId) async {
    final success = await provider.acceptOffer(cargoId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Teklif kabul edildi!' : provider.error ?? 'Hata oluştu'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Cargo cargo;
  final VoidCallback onAccept;

  const _OfferCard({required this.cargo, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RotaxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kargo #${cargo.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (cargo.distributorName != null)
                        Text(
                          cargo.distributorName!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                CargoStatusBadge(status: cargo.status),
              ],
            ),
            const Divider(height: 24),

            // Locations
            _buildLocationRow(
              Icons.circle,
              AppColors.success,
              'Alış',
              cargo.selfLocation?.fullAddress ?? 'Adres belirtilmemiş',
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              Icons.location_on,
              AppColors.error,
              'Teslimat',
              cargo.targetLocation?.fullAddress ?? 'Adres belirtilmemiş',
            ),
            const SizedBox(height: 16),

            // Cargo Details
            if (cargo.measure != null) ...[
              Row(
                children: [
                  _buildDetailChip(Icons.scale, '${cargo.measure?.weight ?? "-"} kg'),
                  const SizedBox(width: 8),
                  _buildDetailChip(Icons.straighten, cargo.measure?.size ?? 'Orta'),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (cargo.description != null && cargo.description!.isNotEmpty) ...[
              Text(
                cargo.description!,
                style: const TextStyle(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: RotaxButton(
                    text: 'Reddet',
                    isOutlined: true,
                    onPressed: () {
                      // TODO: Implement reject
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RotaxButton(
                    text: 'Kabul Et',
                    icon: Icons.check,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
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
              Text(
                address,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
