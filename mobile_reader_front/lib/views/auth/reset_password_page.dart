import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/handlers/auth_handler.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailValidationNotifier = ValueNotifier<bool>(false);
  final passwordValidationNotifier = ValueNotifier<bool>(false);
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;
  bool emailShowError = false;
  bool passwordShowError = false;
  bool _loading = false;
  bool _codeSent = false;
  bool _codeVerified = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _passwordConfirmController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    setState(() {
      emailShowError = _emailController.text.isEmpty ||
          !emailRegex.hasMatch(_emailController.text);
    });

    emailValidationNotifier.value = emailRegex.hasMatch(_emailController.text);
  }

  void _validatePassword() {
    setState(() {
      passwordShowError = _passwordController.text.isEmpty ||
          _passwordController.text.length < 4 ||
          _passwordConfirmController.text.isEmpty ||
          _passwordConfirmController.text.length < 4 ||
          _passwordController.text != _passwordConfirmController.text;
    });

    passwordValidationNotifier.value = _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 4 &&
        _passwordConfirmController.text == _passwordController.text;
  }

  Future<void> _sendResetCode() async {
    setState(() {
      _loading = true;
    });

    await AuthHandler(context: context).sendResetCode(_emailController.text);

    setState(() {
      _loading = false;
      _codeSent = true;
    });
  }

  Future<void> _verifyResetCode() async {
    if (_codeController.text.length == 6) {
      setState(() {
        _loading = true;
      });

      bool isValid = await AuthHandler(context: context)
          .verifyResetCode(_emailController.text, _codeController.text);

      setState(() {
        _loading = false;
        _codeVerified = isValid;
      });

      if (!isValid) {
        if (mounted) {
          showCustomSnackBar(context,
              "Le code est invalide, veuillez réessayer", SnackBarType.error);
        }
        _codeController.clear();
      }
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
    });

    await AuthHandler(context: context).resetPassword(
        _emailController.text, _codeController.text, _passwordController.text);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  prefixIconColor: theme.colorScheme.onBackground,
                  labelText: 'Email',
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                  errorText: emailShowError && _emailController.text.isNotEmpty
                      ? 'Veuillez entrer une adresse email valide'
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                  valueListenable: emailValidationNotifier,
                  builder: (context, isValid, child) {
                    return ElevatedButton(
                      onPressed: isValid ? () => _sendResetCode() : null,
                      child: const Text('Recevoir le code'),
                    );
                  }),
            ] else if (!_codeVerified) ...[
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Entrez le code',
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyResetCode();
                  }
                },
              ),
            ] else ...[
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIconColor: theme.colorScheme.onBackground,
                  prefixIconColor: theme.colorScheme.onBackground,
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                  errorText: passwordShowError &&
                          _passwordController.text.length < 4 &&
                          _passwordController.text.isNotEmpty
                      ? 'Le mot de passe doit faire au moins 4 lettres et être identique au mot de passe de confirmation'
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordConfirmController,
                obscureText: !_passwordConfirmVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIconColor: theme.colorScheme.onBackground,
                  prefixIconColor: theme.colorScheme.onBackground,
                  labelText: 'Confirmer le mot de passe',
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                  errorText: passwordShowError &&
                          _passwordConfirmController.text.length < 4 &&
                          _passwordConfirmController.text.isNotEmpty
                      ? 'Le mot de passe de confirmation doit faire au moins 4 lettres et être identique au mot de passe'
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordConfirmVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordConfirmVisible = !_passwordConfirmVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                  valueListenable: passwordValidationNotifier,
                  builder: (context, isValid, child) {
                    return ElevatedButton(
                      onPressed: isValid ? () => _resetPassword() : null,
                      child: const Text('Mettre à jour le mot de passe'),
                    );
                  }),
            ],
            if (_loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
