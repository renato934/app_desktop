import 'dart:async';
import 'package:flutter/services.dart';

class UserActivityPlugin {
  static const MethodChannel _channel = MethodChannel('user_activity_plugin');

  // Armazena o threshold configurado no Dart para enviar ao nativo
  static Duration _idleThreshold = Duration(seconds: 0);

  /// Define o tempo global que será usado pelo plugin nativo
  static Future<void> setIdleThreshold(Duration duration) async {
    _idleThreshold = duration;
    await _channel.invokeMethod('isUserIdle', {
      'thresholdMillis': _idleThreshold.inMilliseconds,
    });
  }

  /// Retorna true se o usuário está ocioso com base no tempo global configurado
  static Future<bool> isUserIdle() async {
    try {
      final bool result = await _channel.invokeMethod('isUserIdle');
      return result;
    } catch (e) {
      return false;
    }
  }
}
