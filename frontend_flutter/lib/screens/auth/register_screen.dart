import 'package:flutter/material.dart';
import '../../services/aws_cognito_service.dart';
import '../../widgets/minimal_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AwsCognitoService _cognitoService = AwsCognitoService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isVerificationStep = false;

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      bool success = await _cognitoService.signUp(
        _emailController.text.trim(), 
        _passwordController.text.trim()
      );
      if (success) {
        _showSnackBar('Código de seguridad enviado a tu correo.', false);
        setState(() => _isVerificationStep = true);
      }
    } catch (e) {
      _showSnackBar(e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerification() async {
    if (_codeController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      bool success = await _cognitoService.confirmSignUp(
        _emailController.text.trim(), 
        _codeController.text.trim()
      );
      if (success) {
        _showSnackBar('Cuenta creada con éxito. Ya puedes iniciar sesión.', false);
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
    const Color accentBlue = Color(0xFF007AFF);

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
                        Text(
                          _isVerificationStep ? 'Verifica tu cuenta' : 'Crear cuenta',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isVerificationStep 
                            ? 'Introduce el código que enviamos a ${_emailController.text}' 
                            : 'Únete para empezar a tomar el control de tus gastos hoy mismo.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
                        ),
                        const SizedBox(height: 40),

                        if (!_isVerificationStep) ...[
                          MinimalTextField(
                            controller: _emailController,
                            labelText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val!.isEmpty ? 'El correo es obligatorio.' : null,
                          ),
                          const SizedBox(height: 20),
                          MinimalTextField(
                            controller: _passwordController,
                            labelText: 'Contraseña nueva',
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length < 8) return 'Mínimo 8 caracteres.';
                              if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9]).{8,}$').hasMatch(val)) {
                                return 'Usa Mayúscula, número y símbolo especial.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: const Text('Continuar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ] else ...[
                          MinimalTextField(
                            controller: _codeController,
                            labelText: 'Código de confirmación',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34C759),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: const Text('Confirmar Registro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => setState(() => _isVerificationStep = false),
                            child: const Text('Corregir correo electrónico', style: TextStyle(color: accentBlue)),
                          ),
                        ],
                        
                        const SizedBox(height: 40),
                        const Text(
                          'Tu información será procesada de forma segura mediante AWS Cognito Encryption.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
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