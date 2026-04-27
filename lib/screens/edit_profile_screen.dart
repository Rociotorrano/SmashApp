import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/services/ad_service.dart';
import 'package:pantheon/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Future<void> _showEditDialog({
    required String title,
    required String currentValue,
    required List<String> options,
    required Function(String) onSave,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
                  title: Text(option),
                  trailing: currentValue == option
                      ? Icon(Icons.check, color: AppColors.padelBlue)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: currentValue == option
                      ? AppColors.padelBlue.withValues(alpha: 0.1)
                      : null,
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result != null && result != currentValue) {
      onSave(result);
    }
  }

  Future<void> _showTextEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) async {
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      onSave(result);
    }
    controller.dispose();
  }

  Future<void> _updateUser(Function(dynamic) updateFn) async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user == null) return;

    final updatedUser = updateFn(user);
    await authService.updateCurrentUser(updatedUser);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          const SizedBox(height: 24),

          // Nombre
          EditOptionTile(
            icon: Icons.person_outlined,
            title: 'Nombre',
            value: user.name,
            onTap: () => _showTextEditDialog(
              title: 'Editar Nombre',
              currentValue: user.name,
              onSave: (value) => _updateUser((u) => u.copyWith(name: value)),
            ),
          ),

          // Edad (número específico o rango)
          EditOptionTile(
            icon: Icons.cake_outlined,
            title: 'Edad',
            value: '${user.age} años',
            onTap: () => _showTextEditDialog(
              title: 'Editar Edad',
              currentValue: user.age,
              keyboardType: TextInputType.text, // Allow text for ranges
              hint: 'Ingresa tu edad o rango',
              onSave: (value) {
                if (value.isNotEmpty) {
                  _updateUser((u) => u.copyWith(age: value));
                }
              },
            ),
          ),

          // Género
          EditOptionTile(
            icon: Icons.wc_outlined,
            title: 'Género',
            value: user.gender,
            onTap: () => _showEditDialog(
              title: 'Selecciona tu género',
              currentValue: user.gender,
              options: ['Mujer', 'Hombre', 'Prefiero no decirlo'],
              onSave: (value) => _updateUser((u) => u.copyWith(gender: value)),
            ),
          ),

          // Categoría
          EditOptionTile(
            icon: Icons.category_outlined,
            title: 'Categoría',
            value: user.category,
            onTap: () => _showEditDialog(
              title: 'Selecciona tu categoría',
              currentValue: user.category,
              options: ['1ra', '2da', '3ra', '4ta', '5ta', '6ta', '7a', '8a'],
              onSave: (value) =>
                  _updateUser((u) => u.copyWith(category: value)),
            ),
          ),

          // Posición
          EditOptionTile(
            icon: Icons.sports_tennis_outlined,
            title: 'Posición',
            value: user.position,
            onTap: () => _showEditDialog(
              title: 'Selecciona tu posición',
              currentValue: user.position,
              options: ['Drive (derecha)', 'Revés (izquierda)'],
              onSave: (value) =>
                  _updateUser((u) => u.copyWith(position: value)),
            ),
          ),

          // Horario
          EditOptionTile(
            icon: Icons.schedule_outlined,
            title: 'Horario preferido',
            value: user.schedule,
            onTap: () => _showEditDialog(
              title: 'Selecciona tu horario',
              currentValue: user.schedule,
              options: ['Mañana', 'Tarde', 'Noche'],
              onSave: (value) =>
                  _updateUser((u) => u.copyWith(schedule: value)),
            ),
          ),

          // Localidad
          EditOptionTile(
            icon: Icons.location_on_outlined,
            title: 'Localidad',
            value: user.locality,
            onTap: () => _showTextEditDialog(
              title: 'Editar Localidad',
              currentValue: user.locality,
              hint: 'Ej: Mar de Ajó',
              onSave: (value) =>
                  _updateUser((u) => u.copyWith(locality: value)),
            ),
          ),

          // Años jugando
          EditOptionTile(
            icon: Icons.timer_outlined,
            title: 'Años jugando',
            value: '${user.yearsPlaying} años',
            onTap: () => _showTextEditDialog(
              title: 'Años jugando pádel',
              currentValue: user.yearsPlaying.toString(),
              keyboardType: TextInputType.number,
              hint: 'Ingresa los años de experiencia',
              onSave: (value) {
                final years = int.tryParse(value);
                if (years != null && years >= 0) {
                  _updateUser((u) => u.copyWith(yearsPlaying: years));
                }
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Modo Premium (Test)
          SwitchListTile(
            title: const Text('Modo Premium (Sin anuncios)'),
            subtitle: const Text('Activa esto para ocultar toda la publicidad'),
            value: AdService().isPremium,
            onChanged: (value) {
              setState(() {
                AdService().isPremium = value;
              });
              // Reiniciar la app o avisar que se requiere reinicio para ads persistentes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(value
                        ? 'Modo Premium activado'
                        : 'Modo Premium desactivado')),
              );
            },
            secondary: Icon(Icons.star,
                color: AdService().isPremium ? Colors.amber : Colors.grey),
          ),

          const SizedBox(height: 32),

          OutlinedButton(
            onPressed: () async {
              await authService.logout();
              if (context.mounted) context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: Theme.of(context).colorScheme.error, width: 2),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class EditOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const EditOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.padelBlue, size: 28),
        title: Text(
          title,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: value.isNotEmpty
            ? Text(value,
                style: context.textStyles.bodySmall
                    ?.copyWith(color: AppColors.textGrey))
            : null,
        trailing: Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: onTap,
        tileColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
