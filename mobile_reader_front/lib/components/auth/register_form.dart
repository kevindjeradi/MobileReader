import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final Function(String username, String password) onRegister;

  const RegisterForm({Key? key, required this.onRegister}) : super(key: key);

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _passwordVisible = false;
  bool showError = false;
  final validationNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    validationNotifier.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      showError = _passwordController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _passwordController.text.length < 4 ||
          _usernameController.text.length < 4;
    });

    validationNotifier.value = _usernameController.text.isNotEmpty &&
        _usernameController.text.length >= 4 &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 4;
  }

  void _validateAndSubmit() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 4 &&
        username.length >= 4) {
      widget.onRegister(username, password);
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocus,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            prefixIconColor: theme.colorScheme.onBackground,
            labelText: 'Pseudo',
            labelStyle: TextStyle(color: theme.colorScheme.onBackground),
            errorText: showError &&
                    _usernameController.text.length < 4 &&
                    _usernameController.text.isNotEmpty
                ? 'Le pseudo doit faire au moins 4 lettres'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            suffixIconColor: theme.colorScheme.onBackground,
            prefixIconColor: theme.colorScheme.onBackground,
            labelText: 'Mot de passe',
            labelStyle: TextStyle(color: theme.colorScheme.onBackground),
            errorText: showError &&
                    _passwordController.text.length < 4 &&
                    _passwordController.text.isNotEmpty
                ? 'Le mot de passe doit faire au moins 4 lettres'
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
        ValueListenableBuilder<bool>(
            valueListenable: validationNotifier,
            builder: (context, isValid, child) {
              return ElevatedButton(
                onPressed: isValid ? () => _validateAndSubmit() : null,
                child: const Text("S'inscrire"),
              );
            }),
      ],
    );
  }
}
