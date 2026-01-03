import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';
import '../../widgets/rotax_card.dart';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCarType = 'SEDAN';
  WebFile? _selectedImage;
  bool _imageChanged = false;

  final List<Map<String, String>> _carTypes = [
    {'value': 'SEDAN', 'label': 'Sedan'},
    {'value': 'HATCHBACK', 'label': 'Hatchback'},
    {'value': 'SUV', 'label': 'SUV'},
    {'value': 'MINIVAN', 'label': 'Minivan'},
    {'value': 'PICKUP', 'label': 'Pickup'},
    {'value': 'MOTORCYCLE', 'label': 'Motosiklet'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      // TODO: Load carType from user if available in User model
      // For now, default to SEDAN
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Required for web
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImage = WebFile(
          name: result.files.single.name,
          bytes: result.files.single.bytes!,
        );
        _imageChanged = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final driverProvider = context.read<DriverProvider>();
    final authProvider = context.read<AuthProvider>();

    bool success = true;

    // Upload profile picture if changed
    if (_imageChanged && _selectedImage != null) {
      final pictureSuccess = await driverProvider.updateProfilePicture(_selectedImage!);
      if (!pictureSuccess) {
        success = false;
      }
    }

    // Update profile data
    if (success) {
      success = await driverProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        carType: _selectedCarType,
      );
    }

    if (!mounted) return;

    if (success) {
      // Refresh user data
      await authProvider.loadUserInfo();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driverProvider.error ?? 'Profil güncellenirken bir hata oluştu'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  ImageProvider? _getProfileImage(user) {
    if (_selectedImage != null) {
      return MemoryImage(_selectedImage!.bytes);
    } else if (user?.profilePictureUrl != null) {
      return NetworkImage(user!.profilePictureUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final driverProvider = context.watch<DriverProvider>();
    final user = authProvider.user;
    final isLoading = driverProvider.isLoading;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_4.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const RotaxAppBar(
          title: 'Profili Düzenle',
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Card
                RotaxCard(
                  child: Column(
                    children: [
                      const Text(
                        'Profil Fotoğrafı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: isLoading ? null : _pickProfilePicture,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          backgroundImage: _getProfileImage(user),
                          child: _selectedImage == null && user?.profilePictureUrl == null
                              ? Text(
                                  user?.firstName.isNotEmpty == true
                                      ? user!.firstName[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RotaxButton(
                        text: 'Fotoğraf Yükle',
                        icon: Icons.upload_outlined,
                        onPressed: isLoading ? null : _pickProfilePicture,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Information Card
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kişisel Bilgiler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RotaxTextField(
                        controller: _firstNameController,
                        hint: 'Ad',
                        prefixIcon: Icons.person_outline,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      RotaxTextField(
                        controller: _lastNameController,
                        hint: 'Soyad',
                        prefixIcon: Icons.person_outline,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Soyad gerekli';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Information Card
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İletişim Bilgileri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RotaxTextField(
                        controller: _phoneController,
                        hint: 'Telefon Numarası (05XX XXX XX XX)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Telefon numarası gerekli';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicle Information Card
                RotaxCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Araç Bilgileri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCarType,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            dropdownColor: AppColors.cardColor,
                            items: _carTypes.map((type) {
                              return DropdownMenuItem(
                                value: type['value'],
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_car,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      type['label']!,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _selectedCarType = value);
                                    }
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                RotaxButton(
                  text: 'Kaydet',
                  icon: Icons.check,
                  width: double.infinity,
                  onPressed: isLoading ? null : _saveProfile,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
