// import "package:cloud_firestore/cloud_firestore.dart";
// import "package:flutter/material.dart";
// import "package:we_chat/chat_page.dart";
// import "package:we_chat/services/database.dart";
// import "package:we_chat/services/shared_pref.dart";

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? myUsername, myName, myEmail, myPicture;
//   Stream? chatRoomStream;
//   getthesharedpref() async {
//     myUsername = await SharedPreferenceHelper().getUserName();
//     myName = await SharedPreferenceHelper().getUserDisplayName();
//     myEmail = await SharedPreferenceHelper().getUserEmail();
//     myPicture = await SharedPreferenceHelper().getUserImage();
//     setState(() {});
//   }

//   ontheload() async {
//     await getthesharedpref();
//     chatRoomStream = await DatabaseMethods().getChatRooms();
//     setState(() {});
//   }

//   @override
//   void initState() {
//     ontheload();
//     super.initState();
//   }

//   Widget chatRoomList() {
//     return StreamBuilder(
//         stream: chatRoomStream,
//         builder: (context, AsyncSnapshot snapshot) {
//           return snapshot.hasData
//               ? ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: snapshot.data.docs.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     DocumentSnapshot ds = snapshot.data.docs[index];
//                     return ChatRoomListTile(
//                         lastMessage: ds["lastMessage"],
//                         chatRoomId: ds.id,
//                         myUsername: myUsername!,
//                         time: ds["lastMessageSendTs"]);
//                   })
//               : Container();
//         });
//   }

//   TextEditingController searchcontroller = new TextEditingController();
//   bool search = false;

//   var queryResultSet = [];
//   var tempSearchStore = [];

//   getChatRoomIDbyUsername(String a, String b) {
//     if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
//       return "$b\_$a";
//     } else {
//       return "$a\_$b";
//     }
//   }

//   Future<void> initiateSearch(String value) async {
//     value = value.trim();

//     /* A. field cleared → reset */
//     if (value.isEmpty) {
//       setState(() {
//         search = false;
//         queryResultSet = [];
//         tempSearchStore = [];
//       });
//       return;
//     }

//     setState(() => search = true);

//     /* B. helpers */
//     final firstChar = value[0].toUpperCase(); // → “J”
//     final capitalizedValue = firstChar + value.substring(1); // → “John”

//     /* C. first keystroke → hit Firestore once */
//     if (queryResultSet.isEmpty && value.length == 1) {
//       final docs = await DatabaseMethods().Search(firstChar);

//       /* map() + cast prevents null errors later */
//       final fetched =
//           docs.docs.map((d) => d.data() as Map<String, dynamic>).toList();

//       setState(() {
//         queryResultSet = fetched;
//         tempSearchStore = fetched; // show everything after first letter
//       });
//       return; // avoid running the filter below
//     }

//     /* D. second keystroke onward → local filter */
//     setState(() {
//       tempSearchStore = queryResultSet
//           .where((e) =>
//               (e['username'] ?? '').toString().startsWith(capitalizedValue))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff703eff),
//       body: Container(
//         margin: EdgeInsets.only(
//           top: 40,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 20.0),
//               child: Row(
//                 children: [
//                   Image.asset(
//                     "images/wave.png",
//                     height: 50,
//                     width: 50,
//                     fit: BoxFit.cover,
//                   ),
//                   SizedBox(
//                     width: 10.0,
//                   ),
//                   Text(
//                     "Hello, ",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     myName!,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   Spacer(),
//                   Container(
//                     padding: EdgeInsets.all(5),
//                     margin: EdgeInsets.only(right: 20),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Icon(
//                       Icons.person,
//                       color: Color(0xff703eff),
//                       size: 30,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20.0),
//               child: Text(
//                 "Welcome To",
//                 style: TextStyle(
//                     color: Color.fromARGB(197, 255, 255, 255),
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(
//               height: 5.0,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Text(
//                 "WeChat",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 30.0,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(
//               height: 30.0,
//             ),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.only(left: 30, right: 20.0),
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30))),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 30),
//                     Container(
//                       decoration: BoxDecoration(
//                           color: Color(0xFFececf8),
//                           borderRadius: BorderRadius.circular(10)),
//                       child: TextField(
//                         controller: searchcontroller,
//                         onChanged: (value) {
//                           initiateSearch(value.toUpperCase());
//                         },
//                         decoration: InputDecoration(
//                             border: InputBorder.none,
//                             prefixIcon: Icon(Icons.search),
//                             hintText: "Search Username..."),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     search
//                         ? ListView(
//                             padding: EdgeInsets.only(left: 10, right: 10),
//                             primary: false,
//                             shrinkWrap: true,
//                             children: tempSearchStore.map((element) {
//                               return buildResultCard(element);
//                             }).toList())
//                          : chatRoomList() 
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildResultCard(data) {
//     return GestureDetector(
//       onTap: () async {
//         search = false;
//         var chatRoomId = getChatRoomIDbyUsername(myUsername!, data["username"]);

//         Map<String, dynamic> chatInfoMap = {
//           "users": [myUsername, data["username"]],
//         };
//         await DatabaseMethods().createChatRoom(chatRoomId, chatInfoMap);
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => ChatPage(
//                     name: data["Name"],
//                     profileurl: data["Image"],
//                     username: data["username"])));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8),
//         child: Material(
//           elevation: 5,
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//               padding: EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(10)),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                       borderRadius: BorderRadius.circular(60),
//                       child: Image.network(
//                         data["Image"],
//                         height: 70,
//                         width: 70,
//                         fit: BoxFit.cover,
//                       )),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         data["Name"],
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       SizedBox(height: 8.0),
//                       Text(data["username"],
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 15.0,
//                             fontWeight: FontWeight.w500,
//                           ))
//                     ],
//                   )
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
// }

// class ChatRoomListTile extends StatefulWidget {
//   String lastMessage, chatRoomId, myUsername, time;
//   ChatRoomListTile(
//       {required this.lastMessage,
//       required this.chatRoomId,
//       required this.myUsername,
//       required this.time});

//   @override
//   State<ChatRoomListTile> createState() => _ChatRoomListTileState();
// }

// class _ChatRoomListTileState extends State<ChatRoomListTile> {
//   String profilePicUrl = "", name = "", username = "", id = "";

//   getthisUserInfo() async {
//     username =
//         widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
//     QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
//     name = "${querySnapshot.docs[0]["Name"]}";
//     profilePicUrl = "${querySnapshot.docs[0]["Image"]}";
//     id = "${querySnapshot.docs[0]["Id"]}";
//     setState(() {});
//   }

//   @override
//   void initState() {
//     getthisUserInfo();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Material(
//         elevation: 3.0,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: EdgeInsets.all(10),
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               profilePicUrl == ""
//                   ? CircularProgressIndicator()
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(60),
//                       child: Image.network(
//                         profilePicUrl,
//                         height: 70,
//                         width: 70,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//               SizedBox(
//                 width: 10.0,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 10.0,
//                   ),
//                   Text(
//                     name,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20.0,
//                         fontWeight: FontWeight.w500),
//                   ),
//                   Text(
//                     widget.lastMessage,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Color.fromARGB(151, 0, 0, 0),
//                         fontSize: 18.0,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               Text(
//                 widget.time,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 15.0,
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
