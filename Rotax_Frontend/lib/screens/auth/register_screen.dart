import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tcController = TextEditingController();
  final _vknController = TextEditingController();
  
  String _selectedRole = 'DRIVER';
  String _selectedCarType = 'SEDAN';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Web uyumlu dosya listesi
  final List<WebFile> _documents = [];

  final List<Map<String, String>> _roles = [
    {'value': 'DRIVER', 'label': 'Sürücü'},
    {'value': 'DISTRIBUTOR', 'label': 'Dağıtıcı'},
  ];

  final List<Map<String, String>> _carTypes = [
    {'value': 'SEDAN', 'label': 'Sedan'},
    {'value': 'HATCHBACK', 'label': 'Hatchback'},
    {'value': 'SUV', 'label': 'SUV'},
    {'value': 'MINIVAN', 'label': 'Minivan'},
    {'value': 'PICKUP', 'label': 'Pickup'},
    {'value': 'MOTORCYCLE', 'label': 'Motosiklet'},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _tcController.dispose();
    _vknController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate documents for all users
    if (_documents.isEmpty) {
      final docText = _selectedRole == 'DRIVER' 
          ? 'Sürücü belgelerinizi yükleyin (Ehliyet, Ruhsat)'
          : 'Kimlik belgenizi yükleyin (Nüfus Cüzdanı, Ehliyet veya Pasaport)';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(docText),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: _selectedRole,
      tc: _selectedRole == 'DRIVER' ? _tcController.text.trim() : null,
      vkn: _selectedRole == 'DISTRIBUTOR' ? _vknController.text.trim() : null,
      carType: _selectedRole == 'DRIVER' ? _selectedCarType : null,
      documents: _documents.isNotEmpty ? _documents : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // Web için gerekli
    );
    
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.bytes != null) {
            _documents.add(WebFile(
              name: file.name,
              bytes: file.bytes!,
            ));
          }
        }
      });
    }
  }
  
  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
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
        appBar: const RotaxAppBar(title: 'Kayıt Ol', showBackButton: true),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset('assets/images/logo_2.png', height: 80),
                  ),
                  const SizedBox(height: 24),

                  // Role Selection
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: _roles.map((role) {
                        final isSelected = _selectedRole == role['value'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = role['value']!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                role['label']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: RotaxTextField(
                          hint: 'Ad',
                          controller: _firstNameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v?.isEmpty == true ? 'Ad gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RotaxTextField(
                          hint: 'Soyad',
                          controller: _lastNameController,
                          validator: (v) => v?.isEmpty == true ? 'Soyad gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Username
                  RotaxTextField(
                    hint: 'Kullanıcı Adı',
                    controller: _usernameController,
                    prefixIcon: Icons.alternate_email,
                    validator: (v) => v?.isEmpty == true ? 'Kullanıcı adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  RotaxTextField(
                    hint: 'E-posta',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v?.isEmpty == true) return 'E-posta gerekli';
                      if (!v!.contains('@')) return 'Geçerli e-posta girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  RotaxTextField(
                    hint: 'Telefon',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty == true ? 'Telefon gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // Role-specific fields
                  if (_selectedRole == 'DRIVER') ...[
                    RotaxTextField(
                      hint: 'T.C. Kimlik No',
                      controller: _tcController,
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'T.C. gerekli';
                        if (v!.length != 11) return 'T.C. 11 haneli olmalı';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Car Type Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCarType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _carTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_car, color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(type['label']!),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCarType = value!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Document Upload Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _documents.isEmpty ? AppColors.warning.withOpacity(0.5) : AppColors.success.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: _documents.isEmpty ? AppColors.warning : AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Belgeler (Ehliyet, Ruhsat)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${_documents.length} belge',
                                style: TextStyle(
                                  color: _documents.isEmpty ? AppColors.warning : AppColors.success,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Document Preview
                          if (_documents.isNotEmpty) ...[
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _documents.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: MemoryImage(_documents[index].bytes),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Dosya adı
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              _documents[index].name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // Silme butonu
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeDocument(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickDocument,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Belge Seç (Ehliyet, Ruhsat)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Document Upload for Distributor
                  if (_selectedRole == 'DISTRIBUTOR') ...[
                    RotaxTextField(
                      hint: 'Vergi Kimlik No (VKN)',
                      controller: _vknController,
                      prefixIcon: Icons.business_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Kimlik Belgesi Upload Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _documents.isEmpty ? AppColors.warning.withOpacity(0.5) : AppColors.success.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: _documents.isEmpty ? AppColors.warning : AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Kimlik Belgesi (Nüfus Cüzdanı, Ehliyet veya Pasaport)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${_documents.length} belge',
                                style: TextStyle(
                                  color: _documents.isEmpty ? AppColors.warning : AppColors.success,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Document Preview
                          if (_documents.isNotEmpty) ...[
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _documents.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: MemoryImage(_documents[index].bytes),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              _documents[index].name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeDocument(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickDocument,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Kimlik Belgesi Seç'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password
                  RotaxTextField(
                    hint: 'Şifre',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Şifre gerekli';
                      if (v!.length < 6) return 'En az 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  RotaxTextField(
                    hint: 'Şifre Tekrar',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return RotaxButton(
                        text: 'Kayıt Ol',
                        onPressed: _register,
                        isLoading: auth.isLoading,
                        width: double.infinity,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
