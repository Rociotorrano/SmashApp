import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesEstadoService with ChangeNotifier {
  int _noLeidas = 0;
  int get noLeidas => _noLeidas;

  final _supabase = Supabase.instance.client;

  Future<void> actualizarContador() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Por ahora, simulamos o contamos las notificaciones no leídas de la base de datos
      // si existe una tabla de notificaciones. 
      // Si no existe, al menos devolvemos 0 para evitar errores.
      
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('read', false);
      
      _noLeidas = (response as List).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar contador de notificaciones: $e');
      // No lanzamos error para no romper la app si la tabla no existe aún
      _noLeidas = 0;
      notifyListeners();
    }
  }

  void resetContador() {
    _noLeidas = 0;
    notifyListeners();
  }
}
