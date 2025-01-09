import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  // Default selected country for phone number input is USA
  Country selectedCountry = Country(
    phoneCode: '1',
    countryCode: 'US',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'United States',
    example: 'United States',
    displayName: 'United States',
    displayNameNoCountryCode: 'US',
    e164Key: '',
  );

  // Dispose the controller when the widget is removed from the widget tree
  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Build the widget tree for the login screen
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Display a loading animation
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.temple),
              ),
              // Display the app name
              Text(
                'Aegis',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Display instructions for phone number input
              Text(
                'Please enter your phone number to receive a verification code',
                textAlign: TextAlign.center,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              // Input field for phone number
              TextFormField(
                controller: _phoneNumberController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Phone Number',
                  hintStyle: GoogleFonts.titilliumWeb(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.fromLTRB(
                      8.0,
                      12.0,
                      8.0,
                      12.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        // Show country picker for selecting country code
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                        );
                      },
                      child: Text(
                        '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: _phoneNumberController.text.length >= 9
                      ? authProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : InkWell(
                              onTap: () {
                                // Sign in with phone number
                                authProvider.signInWithPhoneNumber(
                                  phoneNumber:
                                      '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                  context: context,
                                );
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}