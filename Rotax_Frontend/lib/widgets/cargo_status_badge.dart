import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/cargo.dart';

class CargoStatusBadge extends StatelessWidget {
  final CargoSituation status;

  const CargoStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 14, color: _getColor()),
          const SizedBox(width: 4),
          Text(
            _getText(),
            style: TextStyle(
              color: _getColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case CargoSituation.CREATED:
        return AppColors.info;
      case CargoSituation.ASSIGNED:
        return AppColors.warning;
      case CargoSituation.PICKED_UP:
        return Colors.orange;
      case CargoSituation.DELIVERED:
        return AppColors.success;
      case CargoSituation.CANCELLED:
      case CargoSituation.FAILED:
        return AppColors.error;
      case CargoSituation.EXPIRED:
        return AppColors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case CargoSituation.CREATED:
        return Icons.add_circle_outline;
      case CargoSituation.ASSIGNED:
        return Icons.person_search;
      case CargoSituation.PICKED_UP:
        return Icons.local_shipping;
      case CargoSituation.DELIVERED:
        return Icons.check_circle;
      case CargoSituation.CANCELLED:
        return Icons.cancel;
      case CargoSituation.FAILED:
        return Icons.error;
      case CargoSituation.EXPIRED:
        return Icons.timer_off;
    }
  }

  String _getText() {
    switch (status) {
      case CargoSituation.CREATED:
        return 'Oluşturuldu';
      case CargoSituation.ASSIGNED:
        return 'Atandı';
      case CargoSituation.PICKED_UP:
        return 'Alındı';
      case CargoSituation.DELIVERED:
        return 'Teslim Edildi';
      case CargoSituation.CANCELLED:
        return 'İptal';
      case CargoSituation.FAILED:
        return 'Başarısız';
      case CargoSituation.EXPIRED:
        return 'Süresi Doldu';
    }
  }
}
