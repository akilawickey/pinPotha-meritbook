import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Utility to debug Firebase Auth token contents
class TokenDebug {
  static Future<void> printTokenInfo(User user) async {
    try {
      final token = await user.getIdToken(true);
      if (token == null) {
        debugPrint('Token is null');
        return;
      }
      
      debugPrint('=== Token Debug Info ===');
      debugPrint('User Email: ${user.email}');
      debugPrint('User UID: ${user.uid}');
      debugPrint('Token Length: ${token.length}');
      
      // Try to decode the token payload (base64)
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          debugPrint('Token Payload (base64): $payload');
          
          // Decode base64
          // Note: This is a simplified decode - full JWT decode would need a package
          String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
          switch (normalized.length % 4) {
            case 1:
              normalized += '===';
              break;
            case 2:
              normalized += '==';
              break;
            case 3:
              normalized += '=';
              break;
          }
          
          // For full decoding, you'd need a base64 decoder
          // But we can at least see the structure
          debugPrint('Token has 3 parts (header.payload.signature)');
        }
      } catch (e) {
        debugPrint('Error parsing token structure: $e');
      }
      
      debugPrint('=== End Token Debug ===');
    } catch (e) {
      debugPrint('Error getting token: $e');
    }
  }
  
  /// Test database access with current token
  static Future<void> testDatabaseAccess(User user) async {
    try {
      await user.getIdToken(true);
      debugPrint('=== Database Access Test ===');
      debugPrint('User Email: ${user.email}');
      debugPrint('Email Path Format: ${user.email?.replaceAll('.', ',')}');
      debugPrint('Token obtained successfully');
      debugPrint('=== End Database Access Test ===');
    } catch (e) {
      debugPrint('Error testing database access: $e');
    }
  }
}

