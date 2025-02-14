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
  static const String groupSettingsScreen = '/groupSettingsScreen';
  static const String groupInformationScreen = '/groupInformationScreen';

  // User Fields
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

  // Contact Fields
  static const String contactName = 'contactName';
  static const String contactImage = 'contactImage';
  static const String contactUID = 'contactUID';

  // Group Fields
  static const String groupID = 'groupID';
  static const String groupModel = 'groupModel';
  static const String groupName = 'groupName';
  static const String groupDescription = 'groupDescription';
  static const String groupImage = 'groupImage';
  static const String isPrivate = 'isPrivate';
  static const String membersUIDs = 'membersUIDs';
  static const String adminsUIDs = 'adminsUIDs';
  static const String awaitingApprovalUIDs = 'awaitingApprovalUIDs';
  static const String groupImages = 'groupImages';

  // Message Fields
  static const String senderUID = 'senderUID';
  static const String senderName = 'senderName';
  static const String senderImage = 'senderImage';
  static const String message = 'message';
  static const String messageType = 'messageType';
  static const String timeSent = 'timeSent';
  static const String messageID = 'messageID';
  static const String isSeen = 'isSeen';
  static const String repliedMessage = 'repliedMessage';
  static const String repliedTo = 'repliedTo';
  static const String repliedMessageType = 'repliedMessageType';
  static const String isMe = 'isMe';
  static const String reactions = 'reactions';
  static const String isSeenBy = 'isSeenBy';
  static const String deletedBy = 'deletedBy';
  static const String lastMessage = 'lastMessage';

  // Chat Fields
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String chatFiles = 'chatFiles';

  // Group Settings
  static const String editSettings = 'editSettings';
  static const String approveMembers = 'approveMembers';
  static const String lockMessages = 'lockMessages';
  static const String requestToJoin = 'requestToJoin';

  // Change Fields
  static const String changeName = 'changeName';
  static const String changeDesc = 'changeDesc';

  // Notification Types
  static const String notificationType = 'notificationType';
  static const String groupChatNotification = 'groupChatNotification';
  static const String chatNotification = 'chatNotification';
  static const String friendRequestNotification = 'friendRequestNotification';
  static const String requestReplyNotification = 'requestReplyNotification';
  static const String groupRequestNotification = 'groupRequestNotification';

  // Miscellaneous
  static const String groups = 'groups';
  static const String isTyping = 'isTyping';
  static const String private = 'private';
  static const String public = 'public';
  static const String creatorUID = 'creatorUID';
}