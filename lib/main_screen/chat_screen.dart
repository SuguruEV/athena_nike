import 'package:athena_nike/constants.dart';
import 'package:athena_nike/models/message_model.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/widgets/bottom_chat_field.dart';
import 'package:athena_nike/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Current User UID
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    // Get Arguments Passed From Previous Screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Get ContactUID From Arguments
    final contactUID = arguments[Constants.contactUID];
    // Get ContactName From Arguments
    final contactName = arguments[Constants.contactName];
    // Get ContactImage From Arguments
    final contactImage = arguments[Constants.contactImage];
    // Get GroupID From Arguments
    final groupID = arguments[Constants.groupID];
    // Check If GroupID is Empty - Then It's A Chat With A User
    final isGroupChat = groupID.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessagesStream(
                      userUID: uid,
                      contactUID: contactUID,
                      isGroup: groupID,
                    ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No Messages',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    final messagesList = snapshot.data!;
                    return GroupedListView<dynamic, DateTime>(
                      reverse: true,
                      elements: messagesList,
                      groupBy: (element) {
                        return DateTime(
                          element.timeSent!.year,
                          element.timeSent!.month,
                          element.timeSent!.day,
                        );
                      },
                      groupHeaderBuilder: (dynamic groupedByValue) => SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              formatDate(groupedByValue.timeSent, [dd, ' ', M, ',', yyyy]),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.titilliumWeb(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ), // optional
                          ),
                        ),
                      ),
                      itemBuilder: (context, dynamic element) {
                        final dateTime = formatDate(
                            element.timeSent!, [hh, ':', nn, ' ', am]);
                        final isMe = element.senderUID == uid;
                        return Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    element.message,
                                    style: GoogleFonts.titilliumWeb(
                                      fontSize: 10,
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dateTime,
                                    style: GoogleFonts.titilliumWeb(
                                      fontSize: 12,
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      groupComparator: (value1, value2) =>
                          value2.compareTo(value1),
                      itemComparator: (item1, item2) {
                        var firstItem = item1.timeSent;
                        var secondItem = item2.timeSent;

                        return secondItem!.compareTo(firstItem!);
                      },
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      order: GroupedListOrder.ASC,
                    );
                  }
                  return const Center(
                    child: Text('No Messages'),
                  );
                },
              ),
            ),
            BottomChatField(
              contactUID: contactUID,
              contactName: contactName,
              contactImage: contactImage,
              groupID: groupID,
            )
          ],
        ),
      ),
    );
  }
}
