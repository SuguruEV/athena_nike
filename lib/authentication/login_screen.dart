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

  Country selectedCountry = Country(
    phoneCode: '34',
    countryCode: 'ES',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Spain',
    example: 'Spain',
    displayName: 'Spain',
    displayNameNoCountryCode: 'ES',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.temple),
              ),
              Text(
                'Aegis',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add your phone number, we will send you a code to verify your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
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
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight: 400,
                            textStyle: GoogleFonts.titilliumWeb(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            inputDecoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: GoogleFonts.titilliumWeb(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onSelect: (country) {
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
                  suffixIcon: _phoneNumberController.text.length == 9 || _phoneNumberController.text.length == 10
                      ? authProvider.isLoading
                          ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                          : InkWell(
                              onTap: () {
                                // Sign In With Phone Number
                                authProvider.signInWithPhoneNumber(
                                  phoneNumber:
                                      '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                  context: context
                                );
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 30,
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
