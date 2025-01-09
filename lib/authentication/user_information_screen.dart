import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/display_user_image.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  // Dispose the controller when the widget is removed from the widget tree
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Build the widget tree for the user information screen
  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authentication =
        context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('User Information'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              // Display user image with option to change
              DisplayUserImage(
                finalFileImage: authentication.finalFileImage,
                radius: 60,
                onPressed: () {
                  authentication.showBottomSheet(
                      context: context, onSuccess: () {});
                },
              ),
              const SizedBox(height: 30),
              // Input field for user name
              TextField(
                controller: _nameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Button to save user information
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: MaterialButton(
                  onPressed: context.read<AuthenticationProvider>().isLoading
                      ? null
                      : () {
                          if (_nameController.text.isEmpty ||
                              _nameController.text.length < 3) {
                            GlobalMethods.showSnackBar(
                                context, 'Please enter a valid name');
                            return;
                          }
                          // Save user data to Firestore
                          saveUserDataToFireStore();
                        },
                  child: context.watch<AuthenticationProvider>().isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save user data to Firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Aegis',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFirestore(
      userModel: userModel,
      onSuccess: () async {
        // Save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        // Navigate to home screen
        navigateToHomeScreen();
      },
      onFail: () async {
        GlobalMethods.showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  // Navigate to the home screen and remove all previous screens
  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}