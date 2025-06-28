import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat/onboarding.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String photoUrl;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _brandPurple = Color(0xff703eff);
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() => _loading = true);

    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
        (route) => false, 
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content:
            const Text('This action is permanent and will remove all data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user == null) throw 'No user logged in';

      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      
      await user.delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Onboarding()),
          (route) => false, 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }


  @override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Scaffold(
        backgroundColor: _brandPurple,
        appBar: AppBar(
          backgroundColor: _brandPurple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(widget.photoUrl),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 35),
                  _ProfileTile(
                    icon: Icons.person_rounded,
                    label: 'Name',
                    value: widget.name,
                  ),
                  const SizedBox(height: 20),
                  _ProfileTile(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: widget.email,
                  ),
                  const SizedBox(height: 40),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'LogOut',
                    onTap: _signOut,
                  ),
                  const SizedBox(height: 16),
                  _ActionTile(
                    icon: Icons.delete_forever_rounded,
                    label: 'Delete Account',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (_loading)
        Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
    ],
  );
}

}

/// Info tile
class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 26),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }
}

// Action tile
class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.iconColor,
      this.textColor});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(icon, color: iconColor ?? Colors.blueGrey, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.black)),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded,
                color: Colors.blueGrey),
          ]),
        ),
      ),
    );
  }
}
