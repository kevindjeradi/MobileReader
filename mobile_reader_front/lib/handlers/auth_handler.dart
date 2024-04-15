// auth_handler.dart
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_navigation.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/provider/auth_provider.dart';
import 'package:mobile_reader_front/provider/theme_color_scheme_provider.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/services/token_service.dart';
import 'package:mobile_reader_front/services/user_service.dart';
import 'package:mobile_reader_front/views/navigation_screen.dart';
import 'package:provider/provider.dart';

class AuthHandler {
  final BuildContext context;

  AuthHandler({
    required this.context,
  });

  Future<void> login(String username, String password) async {
    try {
      final response = await UserService().login(username, password);
      if (response.containsKey('token')) {
        // saving token
        await TokenService().saveToken(response['token']);
        if (context.mounted) {
          // Fetch user details and update providers
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final themeProvider =
              Provider.of<ThemeColorSchemeProvider>(context, listen: false);
          await Api.populateUserProvider(userProvider);
          themeProvider.setThemeByName(userProvider.theme);

          if (context.mounted) {
            CustomNavigation.pushReplacement(context, const NavigationScreen());
            showCustomSnackBar(
                context, 'Connecté avec succès', SnackBarType.success);
          }
        }
      } else {
        if (context.mounted) {
          showCustomSnackBar(
              context, 'Impossible de se connecter', SnackBarType.error);
        }
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
            context, 'Une erreur est survenue -> $error', SnackBarType.error);
      }
    }
  }

  Future<void> register(String username, String password, String email) async {
    try {
      final response = await UserService().signup(username, password, email);
      if (response.containsKey('token')) {
        // saving token
        await TokenService().saveToken(response['token']);

        if (context.mounted) {
          // Then populate the user provider
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          await Api.populateUserProvider(userProvider);
          if (context.mounted) {
            // Log the user in
            final bool isLoggedIn =
                await Provider.of<AuthProvider>(context, listen: false)
                    .login(username, password);
            if (context.mounted) {
              // Making sure the user is logged in before navigating
              if (isLoggedIn) {
                showCustomSnackBar(
                    context,
                    'Inscription et connexion réussies !',
                    SnackBarType.success);
                CustomNavigation.pushReplacement(
                    context, const NavigationScreen());
              } else {
                showCustomSnackBar(
                    context,
                    'Inscription réussie mais erreur de connexion',
                    SnackBarType.error);
              }
            }
          } else {
            // Handle registration failure
            Log.logger.e("An error occurred in register: ${response['error']}");
            if (context.mounted) {
              showCustomSnackBar(
                  context,
                  "Une erreur est survenue: ${response['error']}",
                  SnackBarType.error);
            }
          }
        }
      } else {
        if (context.mounted) {
          showCustomSnackBar(
              context,
              "Une erreur est survenue: ${response['error']}",
              SnackBarType.error);
        }
      }
    } catch (e) {
      // Handle registration error
      Log.logger.e("An error occurred in register: $e");
      if (context.mounted) {
        showCustomSnackBar(
            context, "Une erreur est survenue: $e", SnackBarType.error);
      }
    }
  }

  Future<void> sendResetCode(String email) async {
    try {
      final response = await UserService().sendResetCode(email);
      if (response.containsKey('message')) {
        if (context.mounted) {
          showCustomSnackBar(
              context, response['message'], SnackBarType.success);
        }
      } else {
        if (context.mounted) {
          showCustomSnackBar(context, 'An error occurred', SnackBarType.error);
        }
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
            context, 'An error occurred: $error', SnackBarType.error);
      }
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final response = await UserService().verifyResetCode(email, code);
      if (response.containsKey('message')) {
        if (context.mounted) {
          showCustomSnackBar(
              context, response['message'], SnackBarType.success);
        }
        return true;
      } else {
        if (context.mounted) {
          showCustomSnackBar(context, 'An error occurred', SnackBarType.error);
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
            context, 'An error occurred: $error', SnackBarType.error);
      }
      return false;
    }
  }

  Future<void> resetPassword(String email, String code, String password) async {
    try {
      final response = await UserService().resetPassword(email, code, password);
      if (response.containsKey('message')) {
        if (context.mounted) {
          showCustomSnackBar(
              context, response['message'], SnackBarType.success);
        }
      } else {
        if (context.mounted) {
          showCustomSnackBar(context, 'An error occurred', SnackBarType.error);
        }
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
            context, 'An error occurred: $error', SnackBarType.error);
      }
    }
  }
}
