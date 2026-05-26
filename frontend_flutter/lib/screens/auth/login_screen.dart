import 'package:flutter/material.dart';
import '../../services/aws_cognito_service.dart';
import '../../widgets/minimal_text_field.dart';
import '../dashboard/dashboard_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AwsCognitoService _cognitoService = AwsCognitoService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      String? tokenJWT = await _cognitoService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (tokenJWT != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // Se envia el tokenJWT
            builder: (context) => DashboardLayout(tokenJWT: tokenJWT),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Correo o contraseña incorrectos.', true);
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
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0), 
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: primaryDark)) 
                : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined, 
                        size: 60, 
                        color: Colors.grey, 
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Control de Gastos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700, 
                          letterSpacing: -1.0, 
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gestiona tus finanzas con simplicidad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 48), 

                      MinimalTextField(
                        controller: _emailController,
                        labelText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val!.isEmpty ? 'Requerido.' : null,
                      ),
                      const SizedBox(height: 16),
                      MinimalTextField(
                        controller: _passwordController,
                        labelText: 'Contraseña',
                        obscureText: true,
                        validator: (val) => val!.isEmpty ? 'Requerido.' : null,
                      ),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            '¿Olvidaste tu contraseña?', 
                            style: TextStyle(color: accentBlue, fontSize: 14, fontWeight: FontWeight.w500)
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 0, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Iniciar sesión', 
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2)
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta?', 
                            style: TextStyle(color: Colors.black87, fontSize: 15)
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Regístrate aquí', 
                              style: TextStyle(color: accentBlue, fontSize: 15, fontWeight: FontWeight.w600)
                            ),
                          ),
                        ],
                      ),
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