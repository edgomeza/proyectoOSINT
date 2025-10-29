import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _passwordKey = 'app_password_hash';
  static const String _isFirstLaunchKey = 'is_first_launch';

  encrypt.Key? _encryptionKey;
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  // Generar clave de encriptación desde contraseña
  encrypt.Key _generateKeyFromPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  // Verificar si es el primer lanzamiento
  Future<bool> isFirstLaunch() async {
    final value = await _secureStorage.read(key: _isFirstLaunchKey);
    return value == null;
  }

  // Establecer contraseña inicial
  Future<bool> setInitialPassword(String password) async {
    try {
      final key = _generateKeyFromPassword(password);
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      await _secureStorage.write(key: _passwordKey, value: passwordHash);
      await _secureStorage.write(key: _isFirstLaunchKey, value: 'false');

      _encryptionKey = key;
      _isUnlocked = true;

      return true;
    } catch (e) {
      // Error setting initial password
      return false;
    }
  }

  // Verificar contraseña y desbloquear
  Future<bool> unlockWithPassword(String password) async {
    try {
      final storedHash = await _secureStorage.read(key: _passwordKey);
      if (storedHash == null) return false;

      final inputHash = sha256.convert(utf8.encode(password)).toString();

      if (storedHash == inputHash) {
        _encryptionKey = _generateKeyFromPassword(password);
        _isUnlocked = true;
        return true;
      }

      return false;
    } catch (e) {
      // Error unlocking
      return false;
    }
  }

  // Bloquear aplicación
  Future<void> lock() async {
    _encryptionKey = null;
    _isUnlocked = false;
  }

  // Encriptar datos
  String encryptData(String data) {
    if (_encryptionKey == null) {
      throw Exception('App is locked. Cannot encrypt data.');
    }

    try {
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Combinar IV y datos encriptados
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      // Error encrypting data
      rethrow;
    }
  }

  // Desencriptar datos
  String decryptData(String encryptedData) {
    if (_encryptionKey == null) {
      throw Exception('App is locked. Cannot decrypt data.');
    }

    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // Error decrypting data
      rethrow;
    }
  }

  // Encriptar base de datos al cerrar
  Future<void> encryptDatabase() async {
    if (!_isUnlocked) return;

    try {
      await getDatabasesPath();
      // Aquí puedes implementar la lógica para encriptar archivos sensibles
      // Por ahora, solo cerramos la base de datos
    } catch (e) {
      // Error encrypting database
    }
  }

  // Desencriptar base de datos al abrir
  Future<void> decryptDatabase() async {
    if (!_isUnlocked) {
      throw Exception('App is locked. Cannot decrypt database.');
    }

    try {
      await getDatabasesPath();
      // Aquí puedes implementar la lógica para desencriptar archivos sensibles
    } catch (e) {
      // Error decrypting database
      rethrow;
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final unlocked = await unlockWithPassword(oldPassword);
    if (!unlocked) return false;

    try {
      final newHash = sha256.convert(utf8.encode(newPassword)).toString();
      await _secureStorage.write(key: _passwordKey, value: newHash);

      _encryptionKey = _generateKeyFromPassword(newPassword);
      return true;
    } catch (e) {
      // Error changing password
      return false;
    }
  }
}
