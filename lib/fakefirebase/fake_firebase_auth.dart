// variables for testing
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

const fakeDelay = 5; // in ms

class FakeUserCredential extends Fake implements UserCredential {
  FakeUser? currentFakeUser;

  @override
  FakeUser? get user => currentFakeUser;

  void register(FakeUser fakeUser) {
    currentFakeUser = fakeUser;
  }

  void unregister() {
    currentFakeUser = null;
  }
}

class FakeUser extends Fake implements User {
  FakeUser({this.email, this.password, required this.uid});
  @override
  String? email;
  String? password;
  @override
  String uid;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  // a fake storage of already existing accounts
  List<FakeUser> existingAccounts = [];
  final fakeCredential = FakeUserCredential();

  @override
  FakeUser? get currentUser => fakeCredential.user;

  FakeUser addNewAccount(String email, String password, {String? uid}) {
    final uidinput = uid ?? Uuid().v4().toString();
    final fakeUser = FakeUser(email: email, password: password, uid: uidinput);
    existingAccounts.add(fakeUser);
    return fakeUser;
  }

  @override
  Future<FakeUserCredential> createUserWithEmailAndPassword(
      {required String email, required String password}) {
    // delay for a bit
    Future.delayed(const Duration(milliseconds: fakeDelay));
    // check if email is in use
    for (final fakeUser in existingAccounts) {
      if (fakeUser.email == email) {
        throw FirebaseAuthException(code: 'email-already-in-use');
      }
    }
    final fakeUser = addNewAccount(email, password);
    fakeCredential.register(fakeUser);
    return Future(() => fakeCredential);
  }

  @override
  Future<FakeUserCredential> signInWithEmailAndPassword(
      {required String email, required String password}) {
    // delay for a bit
    Future.delayed(const Duration(milliseconds: fakeDelay));
    // first check if there matches an email
    FakeUser? testuser;
    for (final fakeUser in existingAccounts) {
      if (fakeUser.email == email) testuser = fakeUser;
    }
    if (testuser == null) throw FirebaseAuthException(code: 'user-not-found');

    // check if password is correct
    if (testuser.password != password) {
      throw FirebaseAuthException(code: 'wrong-password');
    }
    fakeCredential.register(testuser);
    return Future(() => fakeCredential);
  }

  @override
  Future<void> signOut() {
    // delay for a bit
    Future.delayed(const Duration(milliseconds: fakeDelay));
    fakeCredential.unregister();
    return Future(() => null);
  }
}
