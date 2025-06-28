import 'package:flutter/material.dart';
import 'package:we_chat/services/auth.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // lets the page scroll on small screens so nothing overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // You can give the image a fixed height or let it size naturally
              Image.asset(
                "images/onboard.png",
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Enjoy the experience of chatting with anyone from around the world",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Connect with people for free",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () => AuthMethods().signInWithGoogle(context),
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 30.0),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff703eff),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/search.png",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text(
                          "Sign in with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20), // a little bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
