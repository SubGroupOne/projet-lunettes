import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'optician/dashboard_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'package:provider/provider.dart';
import 'services/session_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        await prefs.setString('userRole', data['user']['role']);
        await prefs.setInt('userId', data['user']['id']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userEmail', data['user']['email'] ?? _emailController.text);

        if (!mounted) return;

        // 🚀 Fusion des données Guest -> User
        await Provider.of<SessionService>(context, listen: false).mergeGuestData(data['user']['id']);

        final role = data['user']['role'];
        if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboardPage(accessToken: data['accessToken'])));
        } else if (role == 'opticien') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OpticianDashboardPage(accessToken: data['accessToken'])));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(accessToken: data['accessToken'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Échec de la connexion')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              FadeInDown(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.remove_red_eye_rounded, size: 48, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text("Bienvenue sur", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    Text("SMART VISION", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildModernField(
                controller: _emailController,
                label: "Email professionnel ou client",
                icon: Icons.alternate_email_rounded,
                validator: (v) => v!.isEmpty ? 'Veuillez entrer votre email' : null,
              ),
              const SizedBox(height: 24),
              _buildModernField(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscureText,
                onToggleVisibility: () => setState(() => _obscureText = !_obscureText),
                validator: (v) => v!.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage())),
                  child: Text("Mot de passe oublié ?", style: GoogleFonts.inter(color: const Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("SE CONNECTER", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Nouveau ici ?", style: GoogleFonts.inter(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                      child: Text("Créer un compte", style: GoogleFonts.inter(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF0F172A).withOpacity(0.5)),
            suffixIcon: isPassword 
              ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20), onPressed: onToggleVisibility)
              : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }
}
