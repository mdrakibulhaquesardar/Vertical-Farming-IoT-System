import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modules/dashboard/views/glass_card.dart';

Widget deviceCard(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required String value,
      required bool isActive,
      required Color accent,
    }) {
  return GlassCard(
    borderRadius: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: accent, size: 24),
            ),
            const Spacer(),
            Switch(
              value: isActive,
              onChanged: (_) {},
              activeColor: accent,
              inactiveThumbColor: Colors.white24,
              inactiveTrackColor: Colors.white10,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}