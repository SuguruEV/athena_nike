import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // Get the saved theme mode

  void getThemeMode() async {
    // Get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // Check if the saved theme mode is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // Set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // Set the isDarkMode to false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    // Call the getThemeMode function
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Get the UID from Arguments
    final String uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'TitilliumWeb',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          currentUser.uid == uid
              ?
              // Logout Button
              IconButton(
                  onPressed: () {
                    //context.read<AuthenticationProvider>().logout();
                  },
                  icon: const Icon(Icons.logout),
                )
              : const SizedBox(),
        ],
      ),
      body: Center(
          child: Card(
              child: SwitchListTile(
                  title: const Text('Change Theme'),
                  secondary: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? Colors.black : Colors.white),
                      child: Icon(
                          isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                          color: isDarkMode ? Colors.white : Colors.black)),
                  value: isDarkMode,
                  onChanged: (value) {
                    // Set the isDarkMode to the value
                    setState(() {
                      isDarkMode = value;
                    });
                    // Check if the value is true
                    if (value) {
                      // Set the theme mode to dark
                      AdaptiveTheme.of(context).setDark();
                    } else {
                      // Set the theme mode to light
                      AdaptiveTheme.of(context).setLight();
                    }
                  }))),
    );
  }
}
