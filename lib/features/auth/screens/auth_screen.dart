import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../../../core/shared_widgets/custom_text_field.dart';
import '../../../core/shared_widgets/gradient_background.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var bytes = utf8.encode(_passwordController.text);
      var cryptedPassword = sha256.convert(bytes);
      print('Encrypted Hash: $cryptedPassword');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Connexion réussie' : 'Compte créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.35), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.18),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'AeroCare',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestion Médicale Avancée',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      _isLogin ? 'Connexion' : 'Créer un compte',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    if (!_isLogin)
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nom complet',
                        icon: Icons.person,
                        validator: (v) => v!.isEmpty ? 'Ce champ est obligatoire' : null,
                      ),

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'medecin@test.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'L\'email est obligatoire' : (!v.contains('@') ? 'Email invalide' : null),
                    ),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (v) => v!.isEmpty ? 'Le mot de passe est obligatoire' : (v.length < 6 ? 'Trop court' : null),
                    ),

                    if (!_isLogin)
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) => v != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
                      ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire', style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      }),
                      child: Text(_isLogin ? 'Pas de compte ? S\'inscrire' : 'Déjà inscrit ? Se connecter'),
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
