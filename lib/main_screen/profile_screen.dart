import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/my_dialogs.dart';
import 'package:athena_nike/widgets/info_details_card.dart';
import 'package:athena_nike/widgets/manual_screen.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:athena_nike/widgets/settings_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_app_settings/flutter_open_app_settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = context.watch<AuthenticationProvider>();
    bool isMyProfile = uid == authProvider.uid;
    return authProvider.isLoading
        ? const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Saving Image, Please wait...')
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: MyAppBar(
              title: const Text('Profile'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            body: StreamBuilder(
              stream: context
                  .read<AuthenticationProvider>()
                  .userStream(userID: uid),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userModel = UserModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoDetailsCard(
                          userModel: userModel,
                        ),
                        const SizedBox(height: 10),
                        isMyProfile
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'Settings',
                                      style: GoogleFonts.titilliumWeb(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    child: Column(
                                      children: [
                                        SettingsListTile(
                                          title: 'Notifications',
                                          icon: Icons.notifications,
                                          iconContainerColor: Colors.red,
                                          onTap: () {
                                            // Navigate to account settings
                                            FlutterOpenAppSettings
                                                .openAppsSettings(
                                              settingsCode:
                                                  SettingsCode.APP_SETTINGS,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    child: Column(
                                      children: [
                                        SettingsListTile(
                                          title: 'Help',
                                          icon: Icons.help,
                                          iconContainerColor: Colors.yellow,
                                          onTap: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ManualScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        // Added padding for the list tile
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            isDarkMode
                                                ? Icons.nightlight_round
                                                : Icons.wb_sunny_rounded,
                                            color: isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: const Text('Change theme'),
                                      trailing: Switch(
                                          value: isDarkMode,
                                          onChanged: (value) {
                                            // Set the isDarkMode to the value
                                            setState(() {
                                              isDarkMode = value;
                                            });
                                            // Check if the value is true
                                            if (value) {
                                              // Set the theme mode to dark
                                              AdaptiveTheme.of(context)
                                                  .setDark();
                                            } else {
                                              // Set the theme mode to light
                                              AdaptiveTheme.of(context)
                                                  .setLight();
                                            }
                                          }),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    child: Column(
                                      children: [
                                        SettingsListTile(
                                          title: 'Logout',
                                          icon: Icons.logout_outlined,
                                          iconContainerColor: Colors.red,
                                          onTap: () {
                                            MyDialogs.showMyAnimatedDialog(
                                              context: context,
                                              title: 'Logout',
                                              content:
                                                  'Are you sure you want to logout?',
                                              textAction: 'Logout',
                                              onActionTap:
                                                  (value, updatedText) {
                                                if (value) {
                                                  // Logout
                                                  context
                                                      .read<
                                                          AuthenticationProvider>()
                                                      .logout()
                                                      .whenComplete(() {
                                                    Navigator.pop(context);
                                                    Navigator
                                                        .pushNamedAndRemoveUntil(
                                                      context,
                                                      Constants.loginScreen,
                                                      (route) => false,
                                                    );
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
