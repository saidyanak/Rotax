import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/distributor_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/cargo_status_badge.dart';
import '../../models/cargo.dart';
import 'cargo_detail_screen.dart';

class DistributorCargosScreen extends StatefulWidget {
  const DistributorCargosScreen({super.key});

  @override
  State<DistributorCargosScreen> createState() => _DistributorCargosScreenState();
}

class _DistributorCargosScreenState extends State<DistributorCargosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistributorProvider>().loadCargos(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<DistributorProvider>();
        if (!provider.isLoading && provider.hasMore) {
          provider.loadCargos();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          title: 'Kargolarım',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textWhite),
              onPressed: () => context.read<DistributorProvider>().loadCargos(refresh: true),
            ),
          ],
        ),
        body: Consumer<DistributorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.cargos.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.cargos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 80,
                      color: AppColors.textWhite.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kargo yok',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir kargo oluşturmak için + butonuna tıklayın',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadCargos(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.cargos.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.cargos.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }

                  return _CargoListItem(cargo: provider.cargos[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CargoListItem extends StatelessWidget {
  final Cargo cargo;

  const _CargoListItem({required this.cargo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RotaxCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CargoDetailScreen(cargoId: cargo.id),
            ),
          );
        },
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
                        'Kargo #${cargo.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (cargo.createdAt != null)
                        Text(
                          _formatDate(cargo.createdAt!),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                CargoStatusBadge(status: cargo.status),
              ],
            ),
            const Divider(height: 24),

            // From - To
            Row(
              children: [
                Expanded(
                  child: _buildLocationInfo(
                    'Alış Noktası',
                    cargo.selfLocation?.fullAddress ?? 'Belirtilmemiş',
                    Icons.circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildLocationInfo(
                    'Teslimat Noktası',
                    cargo.targetLocation?.fullAddress ?? 'Belirtilmemiş',
                    Icons.location_on,
                    AppColors.error,
                  ),
                ),
              ],
            ),

            // Driver info if assigned
            if (cargo.driverName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Sürücü: ${cargo.driverName}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String address, IconData icon, Color color) {
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
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
