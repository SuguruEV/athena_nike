class Constants {
  // Screen Routes
  static const String landingScreen = '/landingScreen';
  static const String loginScreen = '/loginScreen';
  static const String otpScreen = '/otpScreen';
  static const String userInformationScreen = '/userInformationScreen';
  static const String homeScreen = '/homeScreen';
  static const String chatScreen = '/chatScreen';
  static const String profileScreen = '/profileScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String searchScreen = '/searchScreen';
  static const String friendRequestsScreen = '/friendRequestsScreen';
  static const String friendsScreen = '/friendsScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String privacyPolicyScreen = '/privacyPolicyScreen';
  static const String termsAndConditionsScreen = '/termsAndConditionsScreen';
  static const String settingsScreen = '/settingsScreen';

  static const String uid = 'uid';
  static const String name = 'name';
  static const String phoneNumber = 'phoneNumber';
  static const String image = 'image';
  static const String token = 'token';
  static const String aboutMe = 'aboutMe';
  static const String lastSeen = 'lastSeen';
  static const String createdAt = 'createdAt';
  static const String isOnline = 'isOnline';
  static const String friendsUIDs = 'friendsUIDs';
  static const String friendRequestsUIDs = 'friendRequestsUIDs';
  static const String sentFriendRequestsUIDs = 'sentFriendRequestsUIDs';
  static const String verificationId = 'verificationId';
  static const String users = 'users';
  static const String userImages = 'userImages';
  static const String userModel = 'userModel';

  static const String contactID = 'contactID';
  static const String contactName = 'contactName';
  static const String contactImage = 'contactImage';
  static const String groupID = 'groupID';
}

enum FriendViewType {
  friends,
  friendRequests,
  groupView,
}