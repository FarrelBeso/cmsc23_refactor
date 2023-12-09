import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';

void main() async {
  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });
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
        auth.addNewAccount('test@test.com', '12345678');

        var result = await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        var user = result.user;
        expect(user!.email, 'test@test.com');
        expect(user.password, '12345678');
      });

      test('Logging in and signing out', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.addNewAccount('test@test.com', '12345678');

        await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: '12345678');
        await auth.signOut();
        expect(auth.currentUser, null);
      });

      test('Logging in and signing out', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.addNewAccount('test@test.com', '12345678');

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
            throwsA(predicate((e) =>
                e is FirebaseAuthException && e.code == 'user-not-found')));
      });
      test('Incorrect password', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.addNewAccount('test@test.com', '12345678');
        expect(
            () => auth.signInWithEmailAndPassword(
                email: 'test@test.com', password: '123456789'),
            throwsA(predicate((e) =>
                e is FirebaseAuthException && e.code == 'wrong-password')));
      });
      test('User already exists', () async {
        final auth = FakeFirebaseAuth();
        // assert that there's already an account
        auth.addNewAccount('test@test.com', '12345678');
        expect(
            () => auth.createUserWithEmailAndPassword(
                email: 'test@test.com', password: '123456789'),
            throwsA(predicate((e) =>
                e is FirebaseAuthException &&
                e.code == 'email-already-in-use')));
      });
    });
  });
}
