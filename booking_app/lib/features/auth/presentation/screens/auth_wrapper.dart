import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/screens/admin_home.dart';
import '../../../home/presentation/screens/customer_home.dart';
import '../../../home/presentation/screens/vendor_home.dart';
import 'welcome_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) return const WelcomeScreen();

        final User user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              final String role = roleSnapshot.data!.get('role') ?? 'customer';
              if (role == 'vendor') return const VendorHome();
              if (role == 'admin') return const AdminHome();
              return const CustomerHome();
            }
            return Scaffold(body: Center(child: Text("Error loading profile")));
          },
        );
      },
    );
  }
}