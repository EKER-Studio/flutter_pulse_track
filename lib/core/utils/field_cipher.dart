import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Provides field-level AES-256-CBC encryption and HMAC-SHA256 integrity verification.
class FieldCipher {
  static const int _ivLength = 16;
  static const int _macLength = 32;

  /// Encrypts [plainText] using AES-256 CBC with a fresh random IV and a 32-byte HMAC-SHA256 trailer.
  ///
  /// Payload format: `Base64(IV [16 B] + HMAC [32 B] + Ciphertext [N B])`.
  static String encrypt(String plainText, Uint8List keyBytes) {
    final encKey = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(_ivLength);
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final ivAndCiphertext = Uint8List(_ivLength + encrypted.bytes.length);
    ivAndCiphertext.setRange(0, _ivLength, iv.bytes);
    ivAndCiphertext.setRange(
      _ivLength,
      ivAndCiphertext.length,
      encrypted.bytes,
    );

    final hmac = Hmac(sha256, keyBytes);
    final macBytes = hmac.convert(ivAndCiphertext).bytes;

    final combined = Uint8List(_ivLength + _macLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(_ivLength, _ivLength + _macLength, macBytes);
    combined.setRange(_ivLength + _macLength, combined.length, encrypted.bytes);

    return base64Encode(combined);
  }

  /// Decrypts a Base64 payload produced by [encrypt], verifying the HMAC before decryption.
  static String decrypt(String base64String, Uint8List keyBytes) {
    final combined = base64Decode(base64String);
    if (combined.length < _ivLength) {
      throw const FormatException('Encrypted payload too short');
    }

    final encKey = enc.Key(keyBytes);

    if (combined.length >= _ivLength + _macLength + 16) {
      final ivBytes = combined.sublist(0, _ivLength);
      final macBytes = combined.sublist(_ivLength, _ivLength + _macLength);
      final cipherBytes = combined.sublist(_ivLength + _macLength);

      final ivAndCiphertext = Uint8List(_ivLength + cipherBytes.length);
      ivAndCiphertext.setRange(0, _ivLength, ivBytes);
      ivAndCiphertext.setRange(_ivLength, ivAndCiphertext.length, cipherBytes);

      final hmac = Hmac(sha256, keyBytes);
      final computedMac = hmac.convert(ivAndCiphertext).bytes;

      if (!_constantTimeEquals(macBytes, computedMac)) {
        throw const FormatException('HMAC integrity verification failed');
      }

      final iv = enc.IV(ivBytes);
      final encrypted = enc.Encrypted(cipherBytes);
      final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
      try {
        return encrypter.decrypt(encrypted, iv: iv);
      } catch (e) {
        throw FormatException('Decryption failed: ${e.runtimeType}');
      }
    }

    final ivBytes = combined.sublist(0, _ivLength);
    final cipherBytes = combined.sublist(_ivLength);
    final iv = enc.IV(ivBytes);
    final encrypted = enc.Encrypted(cipherBytes);
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));

    try {
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw FormatException(
        'Decryption or integrity verification failed: ${e.runtimeType}',
      );
    }
  }

  /// Compares two byte arrays in constant time to prevent timing attacks.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
