import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/chat_page.dart';
import 'package:we_chat/services/database.dart';
import 'package:we_chat/services/shared_pref.dart';
import 'package:we_chat/profile.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HOME PAGE
/// ─────────────────────────────────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? myUsername, myName, myEmail, myPicture;

  // ► after we await the future this holds the real stream
  Stream<QuerySnapshot>? chatRoomStream;

  // ── shared‑prefs + stream ──────────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();

    // getChatRooms → Future<Stream<…>>  ⇒ await it once
    chatRoomStream = DatabaseMethods().getChatRooms();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  bool search = false;
  List<Map<String, dynamic>> queryResultSet = [];
  List<Map<String, dynamic>> tempSearchStore = [];

  String _chatRoomIdByUsername(String a, String b) =>
      (a.compareTo(b) > 0) ? '${b}_$a' : '${a}_$b';

  Future<void> initiateSearch(String value) async {
    value = value.trim();
    if (value.isEmpty) {
      setState(() {
        search = false;
        queryResultSet.clear();
        tempSearchStore.clear();
      });
      return;
    }

    setState(() => search = true);

    final firstChar = value[0].toUpperCase();
    final capitalizedValue = firstChar + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      final docs = await DatabaseMethods().Search(firstChar);
      queryResultSet =
          docs.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      tempSearchStore = [...queryResultSet];
      setState(() {});
      return;
    }

    setState(() {
      tempSearchStore = queryResultSet
          .where((e) =>
              (e['username'] ?? '').toString().startsWith(capitalizedValue))
          .toList();
    });
  }

  // ── chat‑room list (stream) ────────────────────────────────────────────────
  Widget chatRoomList() {
    // Wait until _loadInitialData() has resolved the Future
    if (chatRoomStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        // 1. still waiting for first event
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. error → show the message so you know what's wrong
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. empty list → friendly placeholder
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No chats yet'));
        }

        // 4. we have data → build the list
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (_, i) {
            final ds = snapshot.data!.docs[i];
            return ChatRoomListTile(
              lastMessage: ds['lastMessage'] ?? '',
              chatRoomId: ds.id,
              myUsername: myUsername ?? '',
              time: ds['lastMessageSendTs'] ?? '',
            );
          },
        );
      },
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset('images/wave.png', height: 50, width: 50),
                  const SizedBox(width: 10),
                  const Text('Hello, ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(myName ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // 2️⃣  Replace the old Container (profile icon) with this GestureDetector
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            name: myName ?? '',
                            email: myEmail ?? '',
                            photoUrl: myPicture ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person,
                          color: Color(0xff703eff), size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('Welcome To',
                  style: TextStyle(
                      color: Color.fromARGB(197, 255, 255, 255),
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 5),
              child: Text('WeChat',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),

            // white panel
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                child: Column(
                  children: [
                    // search field
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: searchController,
                        onChanged: initiateSearch,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search Username...'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // chat / search list
                    Expanded(
                      child: search
                          ? ListView.builder(
                              itemCount: tempSearchStore.length,
                              itemBuilder: (_, i) =>
                                  _buildResultCard(tempSearchStore[i]),
                            )
                          : chatRoomList(),
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

  // ── search result tile ────────────────────────────────────────────────────
  Widget _buildResultCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        final roomId =
            _chatRoomIdByUsername(myUsername ?? '', data['username']);
        await DatabaseMethods().createChatRoom(roomId, {
          'users': [myUsername, data['username']],
        });

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              name: data['Name'],
              profileurl: data['Image'],
              username: data['username'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                data['Image'],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['Name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(data['username'],
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// CHAT‑ROOM LIST TILE
/// ─────────────────────────────────────────────────────────────────────────────
class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  const ChatRoomListTile(
      {super.key,
      required this.lastMessage,
      required this.chatRoomId,
      required this.myUsername,
      required this.time});
  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String peerUsername = '', peerName = '', peerPicUrl = '';

  Future<void> _fetchPeerInfo() async {
    peerUsername =
        widget.chatRoomId.replaceAll('_', '').replaceAll(widget.myUsername, '');
    final qs = await DatabaseMethods().getUserInfo(peerUsername);
    peerName = qs.docs[0]['Name'] ?? '';
    peerPicUrl = qs.docs[0]['Image'] ?? '';
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchPeerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (peerUsername.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              name: peerName,
              profileurl: peerPicUrl,
              username: peerUsername,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            peerPicUrl.isEmpty
                ? const CircleAvatar(radius: 35)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(peerPicUrl,
                        height: 70, width: 70, fit: BoxFit.cover),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peerName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(widget.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(widget.time,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
