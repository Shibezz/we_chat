import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:we_chat/services/database.dart';
import 'package:we_chat/services/shared_pref.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username;

  const ChatPage({
    super.key,
    required this.name,
    required this.profileurl,
    required this.username,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? messageStream;
  String? myUsername, myName, myEmail, myPicture, chatRoomId, messageId;
  final TextEditingController messagcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  @override
  void dispose() {
    messagcontroller.dispose();
    super.dispose();
  }

  Future<void> onTheLoad() async {
    await getSharedPref();
    if (chatRoomId != null) {
      messageStream =
          DatabaseMethods().getChatRoomMessages(chatRoomId!); // ✅ no await
      setState(() {});
    }
  }

  Future<void> getSharedPref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    chatRoomId = getChatRoomIDbyUsername(widget.username, myUsername!);
  }

  String getChatRoomIDbyUsername(String a, String b) {
    final List<String> sorted = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  void addMessage(bool sendClicked) async {
    if (messagcontroller.text.trim().isEmpty) return;

    String message = messagcontroller.text.trim();
    messagcontroller.clear();

    Map<String, dynamic> messageInfoMap = {
      "message": message,
      "sendBy": myUsername,
      "time": FieldValue.serverTimestamp(),
      "imageUrl": myPicture,
    };

    messageId = randomAlphaNumeric(10);

    await DatabaseMethods().addMessage(chatRoomId!, messageId!, messageInfoMap);

    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": message,
      "lastMessageSendBy": myUsername,
      "time": FieldValue.serverTimestamp(),
    };

    await DatabaseMethods()
        .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
  }

  Widget chatMessageTile(String message, bool sendByMe, Timestamp? timestamp) {
    final timeStr = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '';

    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                bottomRight:
                    sendByMe ? Radius.circular(0) : const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft:
                    sendByMe ? const Radius.circular(24) : Radius.circular(0),
              ),
              color: sendByMe ? Colors.green : Colors.blue,
            ),
            child: Column(
              crossAxisAlignment:
                  sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessage() {
    if (messageStream == null) return Container();

    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          reverse: true, // ✅ latest message at bottom
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return chatMessageTile(
              doc["message"],
              myUsername == doc["sendBy"],
              doc["time"], // 👈 Pass the timestamp
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 4.5),
                  Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(child: chatMessage()),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xff703eff),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: const Icon(Icons.mic,
                                color: Colors.white, size: 35),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFececf8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: messagcontroller,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Write a message",
                                  suffixIcon: Icon(Icons.attach_file),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => addMessage(true),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xff703eff),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
