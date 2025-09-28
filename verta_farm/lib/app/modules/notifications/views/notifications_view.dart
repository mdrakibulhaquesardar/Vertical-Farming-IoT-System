import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Text(
          'No notifications yet',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
