import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_models.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.people, label: 'Kullanıcılar'),
    _NavItem(icon: Icons.description, label: 'Belgeler'),
    _NavItem(icon: Icons.inventory_2, label: 'Kargolar'),
    _NavItem(icon: Icons.account_balance_wallet, label: 'Çekimler'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.dark,
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'ROTAX Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                
                // Nav Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;
                      return _buildNavItem(item, isSelected, () {
                        setState(() => _selectedIndex = index);
                        _loadDataForIndex(index);
                      });
                    },
                  ),
                ),
                
                // Logout
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white70),
                    title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white70)),
                    onTap: _logout,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    hoverColor: Colors.white10,
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(item.icon, color: isSelected ? Colors.white : Colors.white60),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _loadDataForIndex(int index) {
    final adminProvider = context.read<AdminProvider>();
    switch (index) {
      case 0:
        adminProvider.loadDashboard();
        break;
      case 1:
        adminProvider.loadUsers();
        break;
      case 2:
        adminProvider.loadPendingDocuments();
        break;
      case 3:
        adminProvider.loadCargos();
        break;
      case 4:
        adminProvider.loadPendingWithdrawals();
        break;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardView();
      case 1:
        return const _UsersView();
      case 2:
        return const _DocumentsView();
      case 3:
        return const _CargosView();
      case 4:
        return const _WithdrawalsView();
      default:
        return const _DashboardView();
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

// ==================== DASHBOARD VIEW ====================
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final dashboard = provider.dashboard;
        if (dashboard == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(provider.error ?? 'Veriler yüklenemedi'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadDashboard(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.loadDashboard(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Cards
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _StatCard(
                    title: 'Toplam Kullanıcı',
                    value: '${dashboard.totalUsers}',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Aktif Sürücü',
                    value: '${dashboard.activeDrivers}',
                    icon: Icons.directions_car,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Toplam Kargo',
                    value: '${dashboard.totalCargos}',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Bekleyen Onay',
                    value: '${dashboard.pendingVerifications}',
                    icon: Icons.pending_actions,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Second Row Stats
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _StatCard(
                    title: 'Teslim Edilen',
                    value: '${dashboard.deliveredCargos}',
                    icon: Icons.check_circle,
                    color: Colors.teal,
                  ),
                  _StatCard(
                    title: 'Aktif Kargo',
                    value: '${dashboard.activeCargos}',
                    icon: Icons.local_shipping,
                    color: Colors.purple,
                  ),
                  _StatCard(
                    title: 'Toplam Gelir',
                    value: '₺${dashboard.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.indigo,
                  ),
                  _StatCard(
                    title: 'Bekleyen Çekim',
                    value: '₺${dashboard.pendingWithdrawals.toStringAsFixed(0)}',
                    icon: Icons.account_balance,
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== USERS VIEW ====================
class _UsersView extends StatefulWidget {
  const _UsersView();

  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kullanıcılar',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // Role Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedRole,
                            hint: const Text('Tüm Roller'),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Tüm Roller')),
                              DropdownMenuItem(value: 'DRIVER', child: Text('Sürücü')),
                              DropdownMenuItem(value: 'DISTRIBUTOR', child: Text('Dağıtıcı')),
                              DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedRole = value);
                              provider.loadUsers(role: value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => provider.loadUsers(role: _selectedRole),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Users Table
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.dark.withOpacity(0.05),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: Text('Kullanıcı', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('Durum', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('İşlemler', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            // Table Body
                            Expanded(
                              child: ListView.separated(
                                itemCount: provider.users.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final user = provider.users[index];
                                  return _UserRow(user: user);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  final AdminUser user;

  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(user.email)),
          Expanded(child: _RoleBadge(role: user.role)),
          Expanded(child: _StatusBadge(enabled: user.enabled, locked: !user.accountNonLocked)),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(user.enabled ? Icons.block : Icons.check_circle, 
                    color: user.enabled ? AppColors.error : AppColors.success),
                  tooltip: user.enabled ? 'Deaktif Et' : 'Aktif Et',
                  onPressed: () async {
                    await context.read<AdminProvider>().toggleUserStatus(user.id);
                  },
                ),
                IconButton(
                  icon: Icon(user.accountNonLocked ? Icons.lock_open : Icons.lock,
                    color: user.accountNonLocked ? AppColors.warning : AppColors.error),
                  tooltip: user.accountNonLocked ? 'Kilitle' : 'Kilidi Aç',
                  onPressed: () async {
                    await context.read<AdminProvider>().toggleUserLock(user.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (role) {
      case 'ADMIN':
        color = Colors.purple;
        label = 'Admin';
        break;
      case 'DRIVER':
        color = Colors.blue;
        label = 'Sürücü';
        break;
      case 'DISTRIBUTOR':
        color = Colors.orange;
        label = 'Dağıtıcı';
        break;
      default:
        color = Colors.grey;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool enabled;
  final bool locked;

  const _StatusBadge({required this.enabled, required this.locked});

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Kilitli', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        enabled ? 'Aktif' : 'Pasif',
        style: TextStyle(
          color: enabled ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ==================== DOCUMENTS VIEW ====================
class _DocumentsView extends StatefulWidget {
  const _DocumentsView();

  @override
  State<_DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<_DocumentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Belge Onayları',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${provider.pendingDocuments.length} belge onay bekliyor',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.loadPendingDocuments(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Documents Grid
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.pendingDocuments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 80, color: AppColors.success.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Onay bekleyen belge yok',
                                  style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: provider.pendingDocuments.length,
                            itemBuilder: (context, index) {
                              final doc = provider.pendingDocuments[index];
                              return _DocumentCard(document: doc);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final UserDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Document Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                color: Colors.grey.shade200,
                child: document.fileUrl.isNotEmpty
                    ? Image.network(
                        document.fileUrl.startsWith('http') 
                            ? document.fileUrl 
                            : '/api/uploads/${document.fileUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.description, size: 64, color: Colors.grey),
              ),
            ),
          ),
          
          // Document Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentTypeTr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${document.username ?? 'Bilinmeyen'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveDocument(context),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Onayla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reddet'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveDocument(BuildContext context) async {
    final success = await context.read<AdminProvider>().approveDocument(document.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Belge onaylandı' : 'Hata oluştu'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Belgeyi Reddet'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reddetme Sebebi',
            hintText: 'Lütfen bir sebep yazın...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen bir sebep yazın')),
                );
                return;
              }
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().rejectDocument(
                document.id,
                reasonController.text.trim(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Belge reddedildi' : 'Hata oluştu'),
                    backgroundColor: success ? AppColors.warning : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reddet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==================== CARGOS VIEW ====================
class _CargosView extends StatefulWidget {
  const _CargosView();

  @override
  State<_CargosView> createState() => _CargosViewState();
}

class _CargosViewState extends State<_CargosView> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCargos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kargolar',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedStatus,
                            hint: const Text('Tüm Durumlar'),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Tüm Durumlar')),
                              DropdownMenuItem(value: 'PENDING', child: Text('Beklemede')),
                              DropdownMenuItem(value: 'ACCEPTED', child: Text('Kabul Edildi')),
                              DropdownMenuItem(value: 'PICKED_UP', child: Text('Alındı')),
                              DropdownMenuItem(value: 'IN_TRANSIT', child: Text('Yolda')),
                              DropdownMenuItem(value: 'DELIVERED', child: Text('Teslim Edildi')),
                              DropdownMenuItem(value: 'CANCELLED', child: Text('İptal')),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedStatus = value);
                              provider.loadCargos(status: value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => provider.loadCargos(status: _selectedStatus),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cargos Table
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.dark.withOpacity(0.05),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(child: Text('Takip Kodu', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('Güzergah', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('Durum', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('Fiyat', style: TextStyle(fontWeight: FontWeight.bold))),
                                  SizedBox(width: 50),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: provider.cargos.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final cargo = provider.cargos[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(cargo.trackingCode, 
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ),
                                        Expanded(child: Text('${cargo.pickupCity} → ${cargo.deliveryCity}')),
                                        Expanded(child: _CargoStatusBadge(status: cargo.status)),
                                        Expanded(child: Text('₺${cargo.price.toStringAsFixed(0)}')),
                                        SizedBox(
                                          width: 50,
                                          child: cargo.status != 'CANCELLED' && cargo.status != 'DELIVERED'
                                              ? IconButton(
                                                  icon: const Icon(Icons.cancel, color: AppColors.error),
                                                  tooltip: 'İptal Et',
                                                  onPressed: () => _showCancelDialog(context, cargo),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, AdminCargo cargo) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kargoyu İptal Et'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'İptal Sebebi',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await context.read<AdminProvider>().cancelCargo(cargo.id, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('İptal Et', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CargoStatusBadge extends StatelessWidget {
  final String status;

  const _CargoStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'Beklemede';
        break;
      case 'ACCEPTED':
        color = Colors.blue;
        label = 'Kabul Edildi';
        break;
      case 'PICKED_UP':
        color = Colors.indigo;
        label = 'Alındı';
        break;
      case 'IN_TRANSIT':
        color = Colors.purple;
        label = 'Yolda';
        break;
      case 'DELIVERED':
        color = Colors.green;
        label = 'Teslim Edildi';
        break;
      case 'CANCELLED':
        color = Colors.red;
        label = 'İptal';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ==================== WITHDRAWALS VIEW ====================
class _WithdrawalsView extends StatefulWidget {
  const _WithdrawalsView();

  @override
  State<_WithdrawalsView> createState() => _WithdrawalsViewState();
}

class _WithdrawalsViewState extends State<_WithdrawalsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingWithdrawals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çekim Talepleri',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${provider.pendingWithdrawals.length} talep bekliyor',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.loadPendingWithdrawals(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.pendingWithdrawals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 80, color: AppColors.success.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Bekleyen çekim talebi yok',
                                  style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: provider.pendingWithdrawals.length,
                            itemBuilder: (context, index) {
                              final withdrawal = provider.pendingWithdrawals[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.account_balance_wallet, color: AppColors.warning, size: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '@${withdrawal.username ?? 'Kullanıcı #${withdrawal.userId}'}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          if (withdrawal.iban != null)
                                            Text('IBAN: ${withdrawal.iban}', style: const TextStyle(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₺${withdrawal.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 24),
                                    ElevatedButton(
                                      onPressed: () => _approve(context, withdrawal),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                      child: const Text('Onayla', style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => _showRejectDialog(context, withdrawal),
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                      child: const Text('Reddet'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _approve(BuildContext context, PendingWithdrawal withdrawal) async {
    final success = await context.read<AdminProvider>().approveWithdrawal(withdrawal.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Çekim onaylandı' : 'Hata oluştu'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, PendingWithdrawal withdrawal) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çekimi Reddet'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reddetme Sebebi',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await context.read<AdminProvider>().rejectWithdrawal(withdrawal.id, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reddet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
