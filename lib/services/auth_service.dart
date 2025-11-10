import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user not found, wrong password)
      print('Sign in error: ${e.message}');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // After successful signup, create a new document for the user in the 'users' collection
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'currentBookings': [], // Initialize an empty array for bookings
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email already in use)
      print('Sign up error: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
