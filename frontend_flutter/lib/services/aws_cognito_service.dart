import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AwsCognitoService {
  final String _clientId = '4tre8tk0co9c1lgslqiaes347v';
  final String _clientSecret = '1gvnrspt5fqv1qkub6v261v9f9grbs8lhel86qqmqna4mpuhosed';
  final String _endpoint = 'https://cognito-idp.us-east-1.amazonaws.com';

  String _calculateSecretHash(String username) {
    final key = utf8.encode(_clientSecret);
    final bytes = utf8.encode(username + _clientId);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  Future<bool> signUp(String email, String password) async {
    final secretHash = _calculateSecretHash(email);
    
    final Map<String, String> headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp'
    };

    final Map<String, dynamic> body = {
      'ClientId': _clientId,
      'Username': email,
      'Password': password,
      'SecretHash': secretHash,
      'UserAttributes': [
        {'Name': 'email', 'Value': email}
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true; 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error en registro: ${errorData['__type']} - ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('Excepción en SignUp: $e');
      rethrow;
    }
  }

  Future<bool> confirmSignUp(String email, String confirmationCode) async {
    final secretHash = _calculateSecretHash(email);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmSignUp'
    };

    final Map<String, dynamic> body = {
      'ClientId': _clientId,
      'Username': email,
      'ConfirmationCode': confirmationCode,
      'SecretHash': secretHash
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error en confirmación: ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('Excepción en ConfirmSignUp: $e');
      rethrow;
    }
  }

  Future<String?> signIn(String email, String password) async {
    final secretHash = _calculateSecretHash(email);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth'
    };

    final Map<String, dynamic> body = {
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'ClientId': _clientId,
      'AuthParameters': {
        'USERNAME': email,
        'PASSWORD': password,
        'SECRET_HASH': secretHash
      }
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final idToken = responseData['AuthenticationResult']['IdToken'] as String;
        
        return idToken; 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error en inicio de sesión: ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('Excepción en SignIn: $e');
      rethrow;
    }
  }

  Future<bool> forgotPassword(String email) async {
    final secretHash = _calculateSecretHash(email);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.ForgotPassword'
    };

    final Map<String, dynamic> body = {
      'ClientId': _clientId,
      'Username': email,
      'SecretHash': secretHash
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al solicitar recuperación: ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('Excepción en ForgotPassword: $e');
      rethrow;
    }
  }

  Future<bool> confirmForgotPassword(String email, String confirmationCode, String newPassword) async {
    final secretHash = _calculateSecretHash(email);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmForgotPassword'
    };

    final Map<String, dynamic> body = {
      'ClientId': _clientId,
      'Username': email,
      'ConfirmationCode': confirmationCode,
      'Password': newPassword,
      'SecretHash': secretHash
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al cambiar contraseña: ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('Excepción en ConfirmForgotPassword: $e');
      rethrow;
    }
  }
}