import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_model.dart';

// Riverpod Provider (අනිත් අයට මේක පාවිච්චි කරන්න දෙන විදිහ)
final authRepositoryProvider = Provider((ref) => AuthRepository(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  // 1. Register Function
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // A. Email/Password වලින් Account එක හදන්න
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // B. ඉතුරු විස්තර (Name, Role) Database එකේ Save කරන්න
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());
          
    } catch (e) {
      throw e.toString(); // Error එකක් ආවොත් එලියට දානවා
    }
  }

  // 2. Login Function
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }
  
  // 3. Current User ගේ විස්තර ගන්න
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}