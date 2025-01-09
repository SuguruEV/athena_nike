import 'package:athena_nike/constants.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  // Dispose the controllers when the widget is removed from the widget tree
  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // Build the widget tree for the OTP screen
  @override
  Widget build(BuildContext context) {
    // Get the arguments passed to the screen
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    // Define the default theme for the PIN input fields
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.titilliumWeb(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('OTP Verification'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Display the verification title
                  Text(
                    'Verification',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Display instructions for entering the OTP code
                  Text(
                    'Please enter the 6-digit code sent to your phone number',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display the phone number
                  Text(
                    phoneNumber,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Input field for the OTP code
                  SizedBox(
                    height: 68,
                    child: Pinput(
                      length: 6,
                      controller: controller,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      onCompleted: (pin) {
                        setState(() {
                          otpCode = pin;
                        });
                        // Verify the OTP code
                        verifyOTPCode(
                          verificationId: verificationId,
                          otpCode: otpCode!,
                        );
                      },
                      focusedPinTheme: defaultPinTheme.copyWith(
                        height: 68,
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyWith(
                        height: 68,
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Display a loading indicator if the authentication provider is loading
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                  // Display a success icon if the authentication is successful
                  authProvider.isSuccessful
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : const SizedBox.shrink(),
                  // Display a message if the code was not received
                  authProvider.isLoading
                      ? const SizedBox.shrink()
                      : Text(
                          'Didn\'t receive the code?',
                          style: GoogleFonts.titilliumWeb(fontSize: 16),
                        ),
                  const SizedBox(height: 10),
                  // Display a button to resend the code if the timer has expired
                  authProvider.isLoading
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: authProvider.secondsRemaining == 0
                              ? () {
                                  // Resend the code
                                  authProvider.resendCode(
                                    context: context,
                                    phone: phoneNumber,
                                  );
                                }
                              : null,
                          child: Text(
                            'Resend Code',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Verify the OTP code
  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        // Check if the user exists in Firestore
        bool userExists = await authProvider.checkUserExists();

        if (userExists) {
          // If the user exists, get user information from Firestore
          await authProvider.getUserDataFromFirestore();

          // Save user information to provider / shared preferences
          await authProvider.saveUserDataToSharedPreferences();

          // Navigate to the home screen
          navigate(userExits: true);
        } else {
          // If the user doesn't exist, navigate to the user information screen
          navigate(userExits: false);
        }
      },
    );
  }

  // Navigate to the appropriate screen based on user existence
  void navigate({required bool userExits}) {
    if (userExits) {
      // Navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      // Navigate to user information screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}