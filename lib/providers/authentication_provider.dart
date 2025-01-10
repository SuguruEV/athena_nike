import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/user_model.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  int? _resendToken;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  Timer? _timer;
  int _secondsRemaining = 60;

  File? _finalFileImage;
  String _userImage = '';

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  int? get resendToken => _resendToken;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;
  int get secondsRemaining => _secondsRemaining;

  File? get finalFileImage => _finalFileImage;
  String get userImage => _userImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void setFinalFileImage(File? file) {
    _finalFileImage = file;
    notifyListeners();
  }

  // Show bottom sheet for image selection
  void showBottomSheet({
    required BuildContext context,
    required Function() onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(
                  fromCamera: true,
                  onSuccess: () {
                    Navigator.pop(context);
                    onSuccess();
                  },
                  onError: (String error) {
                    GlobalMethods.showSnackBar(context, error);
                  },
                );
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(
                  fromCamera: false,
                  onSuccess: () {
                    Navigator.pop(context);
                    onSuccess();
                  },
                  onError: (String error) {
                    GlobalMethods.showSnackBar(context, error);
                  },
                );
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  // Select image from camera or gallery
  void selectImage({
    required bool fromCamera,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _finalFileImage = await GlobalMethods.pickImage(
      fromCamera: fromCamera,
      onFail: (String message) => onError(message),
    );

    if (finalFileImage == null) {
      return;
    }

    // Crop image
    await cropImage(
      filePath: finalFileImage!.path,
      onSuccess: onSuccess,
    );
  }

  // Crop the selected image
  Future<void> cropImage({
    required String filePath,
    required Function() onSuccess,
  }) async {
    setFinalFileImage(File(filePath));
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    if (croppedFile != null) {
      setFinalFileImage(File(croppedFile.path));
      onSuccess();
    }
  }

  // Check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      // Get user data from Firestore
      await getUserDataFromFirestore();

      // Save user data to shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;
    } else {
      isSignedIn = false;
    }

    return isSignedIn;
  }

  // Check if user exists in Firestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    return documentSnapshot.exists;
  }

  // Update user status (online/offline)
  Future<void> updateUserStatus({required bool value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.isOnline: value});
  }

  // Get user data from Firestore
Future<void> getUserDataFromFirestore() async {
  DocumentSnapshot documentSnapshot =
      await _firestore.collection(Constants.users).doc(_uid).get();
  if (documentSnapshot.exists && documentSnapshot.data() != null) {
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  } else {
    // Handle the case where the document does not exist or data is null
    log('User data not found or is null');
  }
}

  // Save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  // Get user data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // Sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        GlobalMethods.showSnackBar(context, e.toString());
        log('Error: ${e.toString()}');
      },
      codeSent: (String verificationId, int? resendToken) async {
        _isLoading = false;
        _resendToken = resendToken;
        _secondsRemaining = 60;
        _startTimer();
        notifyListeners();
        // Navigate to OTP screen
        Navigator.of(context).pushNamed(
          Constants.otpScreen,
          arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
    );
  }

  // Start the timer for OTP resend
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Resend OTP code
  Future<void> resendCode({
    required BuildContext context,
    required String phone,
  }) async {
    if (_secondsRemaining == 0 || _resendToken != null) {
      _isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          GlobalMethods.showSnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          _resendToken = resendToken;
          notifyListeners();
          GlobalMethods.showSnackBar(context, 'Code sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );
    } else {
      GlobalMethods.showSnackBar(
          context, 'Please wait $_secondsRemaining seconds to resend');
    }
  }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      GlobalMethods.showSnackBar(context, e.toString());
    });
  }

  // Save user data to Firestore
  void saveUserDataToFirestore({
    required UserModel userModel,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_finalFileImage != null) {
        // Upload image to storage
        String imageUrl = await GlobalMethods.storeFileToStorage(
            file: _finalFileImage!,
            reference: '${Constants.userImages}/${userModel.uid}');

        userModel.image = imageUrl;
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      // Save user data to Firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  // Get user stream
  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  // Send friend request
  Future<void> sendFriendRequest({
    required String friendID,
  }) async {
    try {
      // Add our UID to friend's request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });

      // Add friend's UID to our sent friend requests list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  // Cancel friend request
  Future<void> cancelFriendRequest({required String friendID}) async {
    try {
      // Remove our UID from friend's request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      // Remove friend's UID from our sent friend requests list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest({required String friendID}) async {
    // Add our UID to friend's friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });

    // Add friend's UID to our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });

    // Remove our UID from friend's sent friend requests list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // Remove friend's UID from our friend requests list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }

  // Remove friend
  Future<void> removeFriend({required String friendID}) async {
    // Remove our UID from friend's friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // Remove friend's UID from our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }

  // Update user or group image
  Future<String> updateImage({
    required bool isGroup,
    required String id,
  }) async {
    if (_finalFileImage == null) {
      return 'Error';
    }

    _isLoading = true;

    try {
      final String filePath = isGroup
          ? '${Constants.groupImages}/$id'
          : '${Constants.userImages}/$id';

      final String imageUrl = await GlobalMethods.storeFileToStorage(
        file: _finalFileImage!,
        reference: filePath,
      );

      if (isGroup) {
        await _updateGroupImage(id, imageUrl);
        _finalFileImage = null;
        _isLoading = false;
        notifyListeners();
        return imageUrl;
      } else {
        await _updateUserImage(id, imageUrl);
        _userModel!.image = imageUrl;
        _finalFileImage = null;
        _isLoading = false;
        await saveUserDataToSharedPreferences();
        notifyListeners();
        return imageUrl;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Error';
    }
  }

  // Update group image in Firestore
  Future<void> _updateGroupImage(
    String id,
    String imageUrl,
  ) async {
    await _firestore
        .collection(Constants.groups)
        .doc(id)
        .update({Constants.groupImage: imageUrl});
  }

  // Update user image in Firestore
  Future<void> _updateUserImage(
    String id,
    String imageUrl,
  ) async {
    await _firestore
        .collection(Constants.users)
        .doc(id)
        .update({Constants.image: imageUrl});
  }

  // Update user or group name
  Future<String> updateName({
    required bool isGroup,
    required String id,
    required String newName,
    required String oldName,
  }) async {
    if (newName.isEmpty || newName.length < 3 || newName == oldName) {
      return 'Invalid name.';
    }

    if (isGroup) {
      await _updateGroupName(id, newName);
      final nameToReturn = newName;
      newName = '';
      notifyListeners();
      return nameToReturn;
    } else {
      await _updateUserName(id, newName);

      _userModel!.name = newName;
      await saveUserDataToSharedPreferences();
      newName = '';
      notifyListeners();
      return _userModel!.name;
    }
  }

  // Update user or group description
  Future<String> updateStatus({
    required bool isGroup,
    required String id,
    required String newDesc,
    required String oldDesc,
  }) async {
    if (newDesc.isEmpty || newDesc.length < 3 || newDesc == oldDesc) {
      return 'Invalid description.';
    }

    if (isGroup) {
      await _updateGroupDesc(id, newDesc);
      final descToReturn = newDesc;
      newDesc = '';
      notifyListeners();
      return descToReturn;
    } else {
      await _updateAboutMe(id, newDesc);

      _userModel!.aboutMe = newDesc;
      await saveUserDataToSharedPreferences();
      newDesc = '';
      notifyListeners();
      return _userModel!.aboutMe;
    }
  }

  // Update group name in Firestore
  Future<void> _updateGroupName(String id, String newName) async {
    await _firestore.collection(Constants.groups).doc(id).update({
      Constants.groupName: newName,
    });
  }

  // Update user name in Firestore
  Future<void> _updateUserName(String id, String newName) async {
    await _firestore
        .collection(Constants.users)
        .doc(id)
        .update({Constants.name: newName});
  }

  // Update user about me in Firestore
  Future<void> _updateAboutMe(String id, String newDesc) async {
    await _firestore
        .collection(Constants.users)
        .doc(id)
        .update({Constants.aboutMe: newDesc});
  }

  // Update group description in Firestore
  Future<void> _updateGroupDesc(String id, String newDesc) async {
    await _firestore
        .collection(Constants.groups)
        .doc(id)
        .update({Constants.groupDescription: newDesc});
  }

  // Generate a new token for push notifications
  Future<void> generateNewToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();

    log('Token: $token');

    // Save token to Firestore
    _firestore.collection(Constants.users).doc(_userModel!.uid).update({
      Constants.token: token,
    });
  }

  Future<void> logout() async {
    try {
      // Clear user token from Firestore
      await _firestore.collection(Constants.users).doc(_userModel!.uid).update({
        Constants.token: '',
      });
      log('Token cleared from Firestore');

      // Sign out from Firebase Auth
      await _auth.signOut();
      _uid = null;
      _phoneNumber = null;
      _userModel = null;
      _finalFileImage = null; // Clear image
      log('Signed out from Firebase Auth');

      // Clear shared preferences
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      log('Shared preferences cleared');

      notifyListeners();
    } catch (e) {
      log('Error during logout: $e');
    }
  }
}
