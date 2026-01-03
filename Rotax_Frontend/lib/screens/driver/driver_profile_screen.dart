import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_card.dart';
import '../../widgets/rotax_button.dart';
import 'driver_edit_profile_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_4.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const RotaxAppBar(title: 'Profilim'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              RotaxCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: user?.profilePictureUrl != null
                          ? NetworkImage(user!.profilePictureUrl!)
                          : null,
                      child: user?.profilePictureUrl == null
                          ? Text(
                              user?.firstName.isNotEmpty == true
                                  ? user!.firstName[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Sürücü',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Sürücü',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info Card
              RotaxCard(
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email_outlined, 'E-posta', user?.email ?? '-'),
                    const Divider(),
                    _buildInfoRow(Icons.phone_outlined, 'Telefon', user?.phoneNumber ?? '-'),
                    const Divider(),
                    _buildInfoRow(Icons.person_outline, 'Kullanıcı Adı', user?.username ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Menu Items
              RotaxCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.edit_outlined,
                      'Profili Düzenle',
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DriverEditProfileScreen(),
                          ),
                        );
                        // Geri dönünce profili yenile
                        if (context.mounted) {
                          await context.read<AuthProvider>().loadUserInfo();
                        }
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      context,
                      Icons.description_outlined,
                      'Belgelerim',
                      () {
                        // TODO: Navigate to documents
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      context,
                      Icons.directions_car_outlined,
                      'Araç Bilgileri',
                      () {
                        // TODO: Navigate to vehicle info
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      context,
                      Icons.lock_outline,
                      'Şifre Değiştir',
                      () {
                        // TODO: Navigate to change password
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      'Yardım & Destek',
                      () {
                        // TODO: Navigate to help
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              RotaxButton(
                text: 'Çıkış Yap',
                icon: Icons.logout,
                backgroundColor: AppColors.error,
                width: double.infinity,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Çıkış Yap'),
                      content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await context.read<AuthProvider>().logout();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 16),
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
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
