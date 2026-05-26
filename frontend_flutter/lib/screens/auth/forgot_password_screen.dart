import 'package:flutter/material.dart';
import '../../services/aws_cognito_service.dart';
import '../../widgets/minimal_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AwsCognitoService _cognitoService = AwsCognitoService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeSent = false;

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _requestResetCode() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      bool success = await _cognitoService.forgotPassword(_emailController.text.trim());
      if (success) {
        _showSnackBar('Código de recuperación enviado.', false);
        setState(() => _isCodeSent = true);
      }
    } catch (e) {
      _showSnackBar(e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      bool success = await _cognitoService.confirmForgotPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _newPasswordController.text.trim(),
      );
      if (success) {
        _showSnackBar('Contraseña actualizada. Inicia sesión con tus nuevos datos.', false);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDark = Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator(color: primaryDark)),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Recuperar acceso',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (!_isCodeSent) ...[
                          Text(
                            'Ingresa tu correo electrónico para recibir un código de reseteo seguro.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
                          ),
                          const SizedBox(height: 40),
                          MinimalTextField(
                            controller: _emailController,
                            labelText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _requestResetCode, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Enviar Código', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Ingresa el código enviado a ${_emailController.text} y tu nueva contraseña.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
                          ),
                          const SizedBox(height: 40),
                          MinimalTextField(
                            controller: _codeController,
                            labelText: 'Código de Recuperación',
                            keyboardType: TextInputType.number,
                            validator: (val) => val!.isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          MinimalTextField(
                            controller: _newPasswordController,
                            labelText: 'Nueva Contraseña Segura',
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length < 8) return 'Mínimo 8 caracteres';
                              if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$').hasMatch(val)) {
                                return 'Requiere Mayúscula, número y un símbolo especial';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitNewPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34C759),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Actualizar Contraseña', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}