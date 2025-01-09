import 'package:athena_nike/constants.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // Initialize the state of the widget and check authentication status
  @override
  void initState() {
    checkAthentication();
    super.initState();
  }

  // Check the authentication state asynchronously
  void checkAthentication() async {
    // Retrieve the authentication provider from the context
    final authProvider = context.read<AuthenticationProvider>();

    // Check if the user is authenticated
    bool isAuthenticated = await authProvider.checkAuthenticationState();

    // Navigate to the appropriate screen based on authentication status
    navigate(isAuthenticated: isAuthenticated);
  }

  // Navigate to the home screen if authenticated, otherwise to the login screen
  void navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  // Build the widget tree for the landing screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 200,
          child: Column(
            children: [
              // Display a loading animation
              Lottie.asset(AssetsManager.greekLoading),
              // Display a linear progress indicator
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
