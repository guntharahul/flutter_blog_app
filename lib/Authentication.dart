import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthImplemetation {
  Future<String> SignIn(String email, String password);
  Future<String> SignUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();
}

class Auth implements AuthImplemetation {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<String> SignIn(String email, String password) async {
    AuthResult result=await _firebaseAuth.signInWithEmailAndPassword(email: email.toString().trim(), password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> SignUp(String email, String password) async {
    AuthResult result= await _firebaseAuth.createUserWithEmailAndPassword(email: email.toString().trim(), password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<void> signOut() async {
    _firebaseAuth.signOut();
  }
}
