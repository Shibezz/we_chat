// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({
//     super.key,
//     required this.name,
//     required this.email,
//     required this.photoUrl,
//     required this.onLogout,
//     required this.onDeleteAccount,
//   });

//   // ── data coming from caller ────────────────────────────────────────────────
//   final String name;
//   final String email;
//   final String photoUrl;
//   final VoidCallback onLogout;
//   final VoidCallback onDeleteAccount;

//   static const _brandPurple = Color(0xff703eff);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _brandPurple,
//       appBar: AppBar(
//         backgroundColor: _brandPurple,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Profile',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // avatar
//               CircleAvatar(
//                 radius: 55,
//                 backgroundImage: NetworkImage(photoUrl),
//                 backgroundColor: Colors.grey.shade200,
//               ),
//               const SizedBox(height: 35),

//               // name card
//               _ProfileTile(
//                 icon: Icons.person_rounded,
//                 label: 'Name',
//                 value: name,
//               ),
//               const SizedBox(height: 20),

//               // email card
//               _ProfileTile(
//                 icon: Icons.email_rounded,
//                 label: 'Email',
//                 value: email,
//               ),
//               const SizedBox(height: 40),

//               // logout button
//               _ActionTile(
//                 icon: Icons.logout_rounded,
//                 label: 'LogOut',
//                 onTap: onLogout,
//               ),
//               const SizedBox(height: 16),

//               // delete account button
//               _ActionTile(
//                 icon: Icons.delete_forever_rounded,
//                 label: 'Delete Account',
//                 onTap: onDeleteAccount,
//                 iconColor: Colors.redAccent,
//                 textColor: Colors.redAccent,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ─────────────────────────────────────────────────────────────────────────────
// /// Small reusable “info” tile (icon + label + value)
// /// ─────────────────────────────────────────────────────────────────────────────
// class _ProfileTile extends StatelessWidget {
//   const _ProfileTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   final IconData icon;
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 2,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.blueGrey, size: 26),
//             const SizedBox(width: 14),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: const TextStyle(
//                         color: Colors.grey, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 4),
//                 Text(value,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ─────────────────────────────────────────────────────────────────────────────
// /// Action buttons (logout / delete) with arrow
// /// ─────────────────────────────────────────────────────────────────────────────
// class _ActionTile extends StatelessWidget {
//   const _ActionTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.iconColor,
//     this.textColor,
//   });

//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final Color? iconColor;
//   final Color? textColor;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Material(
//         elevation: 2,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: iconColor ?? Colors.blueGrey, size: 26),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(label,
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: textColor ?? Colors.black)),
//               ),
//               const Icon(Icons.keyboard_arrow_right_rounded,
//                   color: Colors.blueGrey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
