import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';
import '../../widgets/cargo_status_badge.dart';
import '../../models/cargo.dart';

class TrackingScreen extends StatefulWidget {
  final String? initialCode;

  const TrackingScreen({super.key, this.initialCode});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _trackingData;

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!;
      _track();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.publicTrack(code));
      setState(() {
        _trackingData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _trackingData = null;
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
        appBar: const RotaxAppBar(title: 'Kargo Takip', showBackButton: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Card
              RotaxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Takip Kodu ile Sorgula',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RotaxTextField(
                            hint: 'Takip kodunu girin',
                            controller: _codeController,
                            prefixIcon: Icons.search,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RotaxButton(
                          text: 'Ara',
                          isLoading: _isLoading,
                          onPressed: _track,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Tracking Result
              if (_trackingData != null) ...[
                _buildTrackingResult(),
              ],

              // Loading
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingResult() {
    final status = _parseStatus(_trackingData?['status']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        RotaxCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kargo #${_trackingData?['id'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CargoStatusBadge(status: status),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Timeline
        RotaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teslimat Durumu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildTimeline(status),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Location Info
        RotaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teslimat Adresi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _trackingData?['targetAddress'] ?? 'Adres bilgisi yok',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Estimated Time
        if (_trackingData?['estimatedDelivery'] != null)
          RotaxCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tahmini Teslimat',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _trackingData?['estimatedDelivery'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Add Note Button
        if (status != CargoSituation.DELIVERED && status != CargoSituation.CANCELLED)
          RotaxButton(
            text: 'Teslimat Notu Ekle',
            icon: Icons.edit_note,
            isOutlined: true,
            width: double.infinity,
            onPressed: () => _showAddNoteDialog(),
          ),
      ],
    );
  }

  Widget _buildTimeline(CargoSituation status) {
    final steps = [
      {'status': CargoSituation.CREATED, 'label': 'Oluşturuldu', 'icon': Icons.add_circle},
      {'status': CargoSituation.ASSIGNED, 'label': 'Sürücü Atandı', 'icon': Icons.person_search},
      {'status': CargoSituation.PICKED_UP, 'label': 'Yola Çıktı', 'icon': Icons.local_shipping},
      {'status': CargoSituation.DELIVERED, 'label': 'Teslim Edildi', 'icon': Icons.check_circle},
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == status);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isCurrent ? AppColors.primary : AppColors.success)
                        : AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    size: 20,
                    color: isCompleted ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.success : AppColors.surfaceColor,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  step['label'] as String,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  CargoSituation _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CREATED':
        return CargoSituation.CREATED;
      case 'ASSIGNED':
        return CargoSituation.ASSIGNED;
      case 'PICKED_UP':
        return CargoSituation.PICKED_UP;
      case 'DELIVERED':
        return CargoSituation.DELIVERED;
      case 'CANCELLED':
        return CargoSituation.CANCELLED;
      default:
        return CargoSituation.CREATED;
    }
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teslimat Notu'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Örn: Komşuya bırakın',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (noteController.text.trim().isEmpty) return;

              try {
                await ApiService.post(
                  ApiConstants.publicTrackNote(_codeController.text),
                  body: {'note': noteController.text},
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not eklendi'),
                      backgroundColor: AppColors.success,
                    ),
                  );
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
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
