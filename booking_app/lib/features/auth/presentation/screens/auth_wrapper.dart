import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../home/presentation/screens/admin_home.dart';
import '../../../home/presentation/screens/customer_home.dart';
import '../../../home/presentation/screens/vendor_home.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. ලොග් වෙලා නැත්නම්
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        // 3. ලොග් වෙලා ඉන්නවා නම් Role එක බලමු
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // වැදගත්: Firestore එකේ Profile එක නැති වුණොත් පෙන්වන මැසේජ් එක
            if (roleSnapshot.hasError) {
              return Scaffold(body: Center(child: Text("Error: ${roleSnapshot.error}")));
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              final data = roleSnapshot.data!.data() as Map<String, dynamic>?;
              final String role = data?['role'] ?? 'customer';

              if (role == 'vendor') return const VendorHome();
              if (role == 'admin') return const AdminHome();
              return const CustomerHome();
            }

            // Profile එක Firestore එකේ නැත්නම් මේක පේනවා
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("User data not found in Firestore!"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: const Text("Logout & Try Again"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}R