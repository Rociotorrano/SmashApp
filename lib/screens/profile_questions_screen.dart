import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/services/user_service.dart';
import 'package:pantheon/theme.dart';

class ProfileQuestionsScreen extends StatefulWidget {
  const ProfileQuestionsScreen({super.key});

  @override
  State<ProfileQuestionsScreen> createState() => _ProfileQuestionsScreenState();
}

class _ProfileQuestionsScreenState extends State<ProfileQuestionsScreen> {
  final _nameController = TextEditingController();
  final _localityController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedAge;
  String? _selectedYearsPlaying;
  String? _selectedCategory;
  String? _selectedPosition;
  String? _selectedSchedule;
  String? _selectedGender;
  String? _selectedHasPlayed;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-completar nombre desde AuthService si está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      if (authService.currentUser?.name != null) {
        _nameController.text = authService.currentUser!.name;
        setState(() {});
      }
    });

    // Cargar foto pendiente si existe
    if (UserService.pendingPhoto != null) {
      _imageFile = UserService.pendingPhoto;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _localityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_nameController.text.isEmpty ||
        (_selectedAge?.isEmpty ?? true) ||
        _selectedYearsPlaying == null ||
        _selectedCategory == null ||
        _selectedPosition == null ||
        _selectedSchedule == null ||
        _selectedGender == null ||
        _selectedHasPlayed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todas las preguntas'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser!;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text,
      age: _selectedAge!,
      yearsPlaying: int.parse(_selectedYearsPlaying!),
      category: _selectedCategory!,
      position: _selectedPosition!,
      schedule: _selectedSchedule!,
      locality: _localityController.text,
      gender: _selectedGender!,
    );

    // Save to backend first
    final success = await UserService.updateProfile(updatedUser);

    if (success) {
      // Upload photo if selected
      if (_imageFile != null) {
        await UserService.uploadPhoto(_imageFile!.path, isMain: true);
        // Limpiar foto pendiente una vez subida
        UserService.pendingPhoto = null;
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al guardar el perfil. Intenta de nuevo.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Refresh user data from backend to ensure we have the new photo URL
    final fullUser = await UserService.getMe();
    if (fullUser != null) {
      await authService.updateCurrentUser(fullUser);
    } else {
      await authService.updateCurrentUser(updatedUser);
    }

    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlueBackground,
      appBar: AppBar(
        title: const Text('Completa tu Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestion('¿Has jugado pádel alguna vez?'),
            _buildRadioGroup(
                ['No, nunca', 'Si, menos de 2 años', 'Si, más de 2 años'],
                _selectedHasPlayed),
            const SizedBox(height: 24),
            _buildQuestion('¿Qué categoría tienes?'),
            _buildChipGroup(
                _selectedHasPlayed == 'No, nunca'
                    ? ['8a']
                    : ['1ra', '2da', '3ra', '4ta', '5ta', '6ta', '7a', '8a'],
                _selectedCategory, (value) {
              setState(() => _selectedCategory = value);
            }),
            const SizedBox(height: 24),
            _buildQuestion('¿Qué posición prefieres jugar?'),
            _buildRadioGroup(['Drive', 'Revés'], _selectedPosition),
            const SizedBox(height: 24),
            _buildQuestion('¿Cuántos años tienes?'),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration: const InputDecoration(
                labelText: 'Tu edad',
                counterText: "", // Hide counter
              ),
              onChanged: (value) {
                setState(() => _selectedAge = value);
              },
            ),
            const SizedBox(height: 24),
            _buildQuestion('Genero'),
            _buildChipGroup(
                ['Mujer', 'Hombre', 'Prefiero no decirlo'], _selectedGender,
                (value) {
              setState(() => _selectedGender = value);
            }),
            const SizedBox(height: 24),
            _buildQuestion('¿En qué horario puedes jugar?'),
            _buildChipGroup(['Mañana', 'Tarde', 'Noche'], _selectedSchedule,
                (value) {
              setState(() => _selectedSchedule = value);
            }),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '¿Cómo te llamas?',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _localityController,
              decoration: const InputDecoration(
                labelText: '¿De qué localidad sos?',
              ),
            ),
            const SizedBox(height: 32),
            _buildQuestion('Tu foto de perfil'),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: _imageFile != null
                          ? AppColors.neonGreen
                          : AppColors.textGrey,
                      width: 2,
                    ),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(File(_imageFile!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Añadir foto',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.textDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('COMPLETAR REGISTRO'),
                    const SizedBox(width: 8),
                    Icon(Icons.sports_tennis, color: AppColors.textDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question) {
    return Text(
      question,
      style: context.textStyles.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRadioGroup(List<String> options, String? selectedValue) {
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          value: option,
          groupValue: selectedValue,
          onChanged: (value) {
            setState(() {
              if (option == 'Drive' || option == 'Revés') {
                _selectedPosition = value;
              } else {
                // Para "¿Has jugado alguna vez?"
                _selectedHasPlayed = value;
                // Asignar años de juego basado en la respuesta
                if (value == 'No, nunca') {
                  _selectedYearsPlaying = '0';
                  _selectedCategory = '8a';
                } else if (value == 'Si, menos de 2 años') {
                  _selectedYearsPlaying = '1';
                } else {
                  _selectedYearsPlaying = '3';
                }
              }
            });
          },
          title: Text(option, style: context.textStyles.bodyMedium),
          activeColor: AppColors.neonGreen,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildChipGroup(List<String> options, String? selectedValue,
      Function(String) onSelected) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          backgroundColor: AppColors.darkSurface,
          selectedColor: AppColors.neonGreen,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.neonGreen : AppColors.textGrey,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
}
