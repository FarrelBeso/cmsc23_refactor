import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

// variables for testing
const fakeDelay = 20; // in ms

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
  FakeUser({this.email, this.password});
  @override
  String? email;
  @override
  String uid = const Uuid().v4();
  String? password;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  // a fake storage of already existing accounts
  List<FakeUser> existingAccounts = [];
  final fakeCredential = FakeUserCredential();

  @override
  FakeUser? get currentUser => fakeCredential.user;

  FakeUser addNewAccount(String email, String password) {
    final fakeUser = FakeUser(email: email, password: password);
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

void main() async {
  group('Sanity Check for self-defined fake firebase auth', () {
    group('Happy Paths', () {
      test('Signing in', () async {
        final auth = FakeFirebaseAuth();
        var result = await auth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        var user = result.user;
        expect(user!.email, 'test@test.com');
        expect(user.password, '12345678');
      });
      test('Signing in then signing out', () async {
        final auth = FakeFirebaseAuth();
        await auth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        await auth.signOut();
        expect(auth.currentUser, null);
      });

      test('Logging in', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.existingAccounts
            .add(FakeUser(email: 'test@test.com', password: '12345678'));

        var result = await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        var user = result.user;
        expect(user!.email, 'test@test.com');
        expect(user.password, '12345678');
      });

      test('Logging in and signing out', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.existingAccounts
            .add(FakeUser(email: 'test@test.com', password: '12345678'));

        await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        await auth.signOut();
        expect(auth.currentUser, null);
      });

      test('Logging in and signing out', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.existingAccounts
            .add(FakeUser(email: 'test@test.com', password: '12345678'));

        await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        await auth.signOut();
        expect(auth.currentUser, null);
      });

      test('New Account, Sign Out, Login', () async {
        final auth = FakeFirebaseAuth();
        await auth.createUserWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        await auth.signOut();
        var result = await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        var user = result.user;
        expect(user!.email, 'test@test.com');
        expect(user.password, '12345678');
      });

      test(
          'New Account, Sign Out, Another New Account, Sign Out, Login to first account',
          () async {
        final auth = FakeFirebaseAuth();
        await auth.createUserWithEmailAndPassword(
            email: 'test1@test.com', password: '12345678');
        await auth.signOut();
        await auth.createUserWithEmailAndPassword(
            email: 'test2@test.com', password: '12345678');
        await auth.signOut();
        var result = await auth.signInWithEmailAndPassword(
            email: 'test1@test.com', password: '12345678');
        var user = result.user;
        expect(user!.email, 'test1@test.com');
        expect(user.password, '12345678');
      });
    });

    group('Sad Path', () {
      test('User does not exist', () async {
        final auth = FakeFirebaseAuth();
        expect(
            () => auth.signInWithEmailAndPassword(
                email: 'test@test.com', password: '12345678'),
            throwsA(isInstanceOf<FirebaseAuthException>()));
      });
    });
  });
}
