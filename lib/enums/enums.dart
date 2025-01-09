// Enum representing different views for friends
enum FriendViewType {
  friends,        // View for friends
  friendRequests, // View for friend requests
  groupView,      // View for groups
  allUsers,       // View for all users
}

// Enum representing different types of messages
enum MessageEnum {
  text,   // Text message
  image,  // Image message
  video,  // Video message
  audio,  // Audio message
}

// Enum representing different types of groups
enum GroupType {
  private, // Private group
  public,  // Public group
  none,    // No group
}

// Extension on String to convert it to MessageEnum
extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      default:
        return MessageEnum.text;
    }
  }
}