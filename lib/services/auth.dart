import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/home.dart';
import 'package:we_chat/services/database.dart';
import 'package:we_chat/services/shared_pref.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn.standard();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;
    String username=userDetails!.email!.replaceAll("@gmail.com","");
    String firstletter=username.substring(0,1).toUpperCase();
    await SharedPreferenceHelper().saveUserDisplayName(userDetails.displayName!);
    await SharedPreferenceHelper().saveUserEmail(userDetails.email!);
    await SharedPreferenceHelper().saveUserId(userDetails.uid);
    await SharedPreferenceHelper().saveUserName(username);
    await SharedPreferenceHelper().saveUserImage(userDetails.photoURL!);


    Map<String, dynamic> userInfoMap = {
      "Name": userDetails.displayName,
      "Email": userDetails.email,
      "Image": userDetails.photoURL,
      "Id": userDetails.uid,
      "username":username.toUpperCase(),
      "SearchKey":firstletter,
    };

    await DatabaseMethods()
        .addUser(userInfoMap, userDetails.uid)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Registered Sucessfully",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          )));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
    });
    }
}
