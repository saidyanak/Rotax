import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/distributor_provider.dart';
import '../../widgets/rotax_app_bar.dart';
import '../../widgets/rotax_button.dart';
import '../../widgets/rotax_text_field.dart';
import '../../widgets/rotax_card.dart';

class CreateCargoScreen extends StatefulWidget {
  const CreateCargoScreen({super.key});

  @override
  State<CreateCargoScreen> createState() => _CreateCargoScreenState();
}

class _CreateCargoScreenState extends State<CreateCargoScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Cargo Info
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  // Self Location
  final _selfAddressController = TextEditingController();
  final _selfCityController = TextEditingController();
  final _selfDistrictController = TextEditingController();

  // Target Location
  final _targetAddressController = TextEditingController();
  final _targetCityController = TextEditingController();
  final _targetDistrictController = TextEditingController();

  // Measure
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedSize = 'MEDIUM';

  final List<Map<String, String>> _sizes = [
    {'value': 'SMALL', 'label': 'Küçük'},
    {'value': 'MEDIUM', 'label': 'Orta'},
    {'value': 'LARGE', 'label': 'Büyük'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _selfAddressController.dispose();
    _selfCityController.dispose();
    _selfDistrictController.dispose();
    _targetAddressController.dispose();
    _targetCityController.dispose();
    _targetDistrictController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _createCargo() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DistributorProvider>();
    final success = await provider.createCargo(
      description: _descriptionController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      selfLocation: {
        'address': _selfAddressController.text.trim(),
        'city': _selfCityController.text.trim(),
        'district': _selfDistrictController.text.trim(),
        'latitude': 41.0082, // TODO: Get from map
        'longitude': 28.9784,
      },
      targetLocation: {
        'address': _targetAddressController.text.trim(),
        'city': _targetCityController.text.trim(),
        'district': _targetDistrictController.text.trim(),
        'latitude': 41.0082,
        'longitude': 28.9784,
      },
      measure: {
        'weight': double.tryParse(_weightController.text) ?? 0,
        'length': double.tryParse(_lengthController.text) ?? 0,
        'width': double.tryParse(_widthController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0,
        'size': _selectedSize,
      },
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kargo başarıyla oluşturuldu!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Bir hata oluştu'),
          backgroundColor: AppColors.error,
        ),
      );
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
        appBar: const RotaxAppBar(title: 'Yeni Kargo', showBackButton: true),
        body: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _createCargo();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: RotaxButton(
                          text: 'Geri',
                          isOutlined: true,
                          onPressed: details.onStepCancel,
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<DistributorProvider>(
                        builder: (context, provider, _) {
                          return RotaxButton(
                            text: _currentStep == 2 ? 'Oluştur' : 'İleri',
                            isLoading: provider.isLoading,
                            onPressed: details.onStepContinue,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Kargo Bilgileri', style: TextStyle(color: AppColors.textWhite)),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: _buildCargoInfoStep(),
              ),
              Step(
                title: const Text('Adres Bilgileri', style: TextStyle(color: AppColors.textWhite)),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: _buildAddressStep(),
              ),
              Step(
                title: const Text('Paket Boyutları', style: TextStyle(color: AppColors.textWhite)),
                isActive: _currentStep >= 2,
                content: _buildMeasureStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCargoInfoStep() {
    return RotaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotaxTextField(
            hint: 'Kargo Açıklaması',
            controller: _descriptionController,
            prefixIcon: Icons.description,
            maxLines: 3,
            validator: (v) => v?.isEmpty == true ? 'Açıklama gerekli' : null,
          ),
          const SizedBox(height: 16),
          RotaxTextField(
            hint: 'Alıcı Telefonu',
            controller: _phoneController,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (v) => v?.isEmpty == true ? 'Telefon gerekli' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Column(
      children: [
        // Self Location
        RotaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 12, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Alış Adresi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RotaxTextField(
                hint: 'Adres',
                controller: _selfAddressController,
                prefixIcon: Icons.location_on,
                validator: (v) => v?.isEmpty == true ? 'Adres gerekli' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RotaxTextField(
                      hint: 'Şehir',
                      controller: _selfCityController,
                      validator: (v) => v?.isEmpty == true ? 'Şehir gerekli' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RotaxTextField(
                      hint: 'İlçe',
                      controller: _selfDistrictController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Target Location
        RotaxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'Teslimat Adresi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RotaxTextField(
                hint: 'Adres',
                controller: _targetAddressController,
                prefixIcon: Icons.location_on,
                validator: (v) => v?.isEmpty == true ? 'Adres gerekli' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RotaxTextField(
                      hint: 'Şehir',
                      controller: _targetCityController,
                      validator: (v) => v?.isEmpty == true ? 'Şehir gerekli' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RotaxTextField(
                      hint: 'İlçe',
                      controller: _targetDistrictController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureStep() {
    return RotaxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Boyut Seçin',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: _sizes.map((size) {
              final isSelected = _selectedSize == size['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSize = size['value']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          size['value'] == 'SMALL'
                              ? Icons.inbox
                              : size['value'] == 'MEDIUM'
                                  ? Icons.inventory_2
                                  : Icons.warehouse,
                          color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size['label']!,
                          style: TextStyle(
                            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Detaylı Ölçüler (Opsiyonel)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RotaxTextField(
                  hint: 'Ağırlık (kg)',
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RotaxTextField(
                  hint: 'Uzunluk (cm)',
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RotaxTextField(
                  hint: 'Genişlik (cm)',
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RotaxTextField(
                  hint: 'Yükseklik (cm)',
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
