import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final Function(String username, String password, String email) onRegister;

  const RegisterForm({Key? key, required this.onRegister}) : super(key: key);

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _passwordVisible = false;
  bool showError = false;
  final validationNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    validationNotifier.dispose();
    super.dispose();
  }

  void _validateFields() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    final isUsernameValid = _usernameController.text.length >= 4;
    final isPasswordValid = _passwordController.text.length >= 4;
    final isEmailValid = emailRegex.hasMatch(_emailController.text);

    setState(() {
      showError = !isUsernameValid || !isPasswordValid || !isEmailValid;
    });

    validationNotifier.value =
        isUsernameValid && isPasswordValid && isEmailValid;
  }

  void _validateAndSubmit() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final email = _emailController.text;
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 4 &&
        username.length >= 4 &&
        email.isNotEmpty) {
      widget.onRegister(username, password, email);
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  Widget _buildValidationConditions() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    final isUsernameValid = _usernameController.text.length >= 4;
    final isPasswordValid = _passwordController.text.length >= 4;
    final isEmailValid = emailRegex.hasMatch(_emailController.text);

    // Helper method to create each condition row
    Widget conditionRow(String text, bool isValid) {
      return Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: isValid ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: isValid ? Colors.green : Colors.grey),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        conditionRow(
            "Le pseudo doit faire au moins 4 lettres", isUsernameValid),
        const SizedBox(height: 4),
        conditionRow(
            "L'email doit être une adresse email valide", isEmailValid),
        const SizedBox(height: 4),
        conditionRow("Le mot de passe doit faire au moins 4 caractères",
            isPasswordValid),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocus,
          onSubmitted: (_) => _emailFocus.requestFocus(),
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
          controller: _emailController,
          focusNode: _emailFocus,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            prefixIconColor: theme.colorScheme.onBackground,
            labelText: 'Email',
            labelStyle: TextStyle(color: theme.colorScheme.onBackground),
            errorText: showError && _emailController.text.isNotEmpty
                ? 'Veuillez entrer une adresse email valide'
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
        _buildValidationConditions(),
        const SizedBox(height: 16),
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
