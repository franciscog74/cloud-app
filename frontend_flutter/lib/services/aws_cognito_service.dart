import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AwsCognitoService {
  final String _clientId = dotenv.env['AWS_COGNITO_CLIENT_ID'] ?? '';
  final String _clientSecret = dotenv.env['AWS_COGNITO_CLIENT_SECRET'] ?? '';
  final String _endpoint = dotenv.env['AWS_COGNITO_ENDPOINT'] ?? '';

  /// Calcula el SECRET_HASH requerido por AWS Cognito cuando un Client App posee un Client Secret.
  /// La fórmula matemática de AWS: Base64(HMAC-SHA256(ClientSecret, Username + ClientId))
  String _calculateSecretHash(String username) {
    final key = utf8.encode(_clientSecret);
    final bytes = utf8.encode(username + _clientId);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// Registra un nuevo usuario en el sistema de control de gastos utilizando  correo electrónico.
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

  /// Confirma el código que Cognito envia
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

  /// Inicia sesión y extrae los tokens
  /// Da el Token JWT completo para pasarlo al Backend
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

  /// Solicita a AWS Cognito que envíe un coigo de recuperación al correo del usuario
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

  /// Confirma la nueva contraseña utilizando el codigo 
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