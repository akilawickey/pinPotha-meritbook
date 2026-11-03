import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pinpotha/main.dart';
import 'package:pinpotha/models/post.dart';
import 'package:pinpotha/providers/auth_provider.dart';
import 'package:pinpotha/screens/post_list_screen.dart';
import 'package:pinpotha/screens/add_post_screen.dart';
import 'package:pinpotha/utils/date_utils.dart';
import 'support/fake_repository.dart';

class TestUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  String get displayName => uid;
  TestUser(this.uid, this.email);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StreamController<User?> authChanges;
  late FakeRepository repository;
  late User account;
  setUp(() {
    authChanges = StreamController<User?>.broadcast();
    repository = FakeRepository();
    account = TestUser('A', 'a@example.com');
    PackageInfo.setMockInitialValues(
        appName: 'PinPotha',
        packageName: 'asak.pro.pinPotha',
        version: '5.7',
        buildNumber: '18',
        buildSignature: '');
  });
  tearDown(() async {
    await authChanges.close();
    await repository.close();
  });
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(PinPothaApp(
        repository: repository,
        authFactory: () => AuthProvider(
              authChanges: authChanges.stream,
              signInAction: () async {
                authChanges.add(account);
              },
              signOutAction: () async {
                authChanges.add(null);
              },
            )));
    authChanges.add(null);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'four tabs preserve auth gate through logout, relogin and account change',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(repository.activeSubscriptions, 1);
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Version 5.7 (18)'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(repository.activeSubscriptions, 0);
    account = TestUser('B', 'b@example.com');
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('PinPotha'), findsOneWidget);
    expect(repository.activeSubscriptions, 1);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('b@example.com'), findsOneWidget);
    expect(find.text('a@example.com'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(repository.activeSubscriptions, 0);
  });
  testWidgets(
      'calendar day connects to selected-day creation and original bucket details',
      (tester) async {
    final date = AppDateUtils.getStartOfDay(DateTime.now());
    final dateKey = AppDateUtils.formatDate(date);
    repository.records['a@example.com'] = [
      Post.fromJson({
        'note': 'පින් දහම්',
        'timeStamp': {'server_time': date.millisecondsSinceEpoch}
      }, 'legacy', '01-01-2020')
    ];
    await open(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('day-$dateKey')));
    await tester.pumpAndSettle();
    expect(find.byType(PostListScreen), findsOneWidget);
    expect(find.text('පින් දහම්'), findsOneWidget);
    await tester.tap(find.text('Add Good Thought'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPostScreen), findsOneWidget);
    expect(find.text(AppDateUtils.formatDate(date, format: 'dd MMMM yyyy')),
        findsOneWidget);
    await tester.enterText(find.byType(TextField), 'selected day note');
    await tester.tap(find.text('Post Good Thought'));
    await tester.pumpAndSettle();
    expect(repository.saves.single.dateKey, dateKey);
    expect(find.byType(PostListScreen), findsNothing);
    expect(repository.activeSubscriptions, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets(
      'search matches dates and Sinhala notes; tab changes retain unsaved draft',
      (tester) async {
    repository.records['a@example.com'] = [
      Post.fromJson({
        'note': 'පින් දහම්',
        'timeStamp': {
          'server_time': DateTime(2020, 2, 29).millisecondsSinceEpoch
        }
      }, 'old', '29-02-2020')
    ];
    await open(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '29-02-2020');
    await tester.pumpAndSettle();
    expect(find.text('පින් දහම්'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pumpAndSettle();
    expect(find.text('No matching good thoughts.'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'keep my draft');
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('keep my draft'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('system back pops day list and protects a dirty routed form',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    final key = ValueKey('day-${AppDateUtils.formatDate(DateTime.now())}');
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(PostListScreen), findsNothing);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Good Thought'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'protect this draft');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard draft?'), findsOneWidget);
    await tester.tap(find.text('Keep draft'));
    await tester.pumpAndSettle();
    expect(find.text('protect this draft'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('failed sign-in keeps its error visible and allows retry',
      (tester) async {
    await tester.pumpWidget(PinPothaApp(
        repository: repository,
        authFactory: () => AuthProvider(
              authChanges: authChanges.stream,
              signInAction: () async {
                throw StateError('network failure');
              },
            )));
    authChanges.add(null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in failed. Check your connection and try again.'),
        findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byWidgetPredicate((widget) => widget is FilledButton))
            .onPressed,
        isNotNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('calendar and Add fit a small phone viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
