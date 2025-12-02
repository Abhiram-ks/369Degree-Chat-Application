import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_bubles.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';

void main() {
  group('MessageBubleWidget Tests', () {
    testWidgets('should display message text', (WidgetTester tester) async {
      // TODO: Implement widget test
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Scaffold(
      //       body: MessageBubleWidget(
      //         message: 'Test message',
      //         time: '12:00',
      //         docId: '1',
      //         isCurrentUser: true,
      //         status: MessageStatus.sent,
      //       ),
      //     ),
      //   ),
      // );
      // 
      // expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('should show correct status icon for current user', (WidgetTester tester) async {
      // TODO: Implement test
    });

    testWidgets('should not show status icon for other users', (WidgetTester tester) async {
      // TODO: Implement test
    });
  });
}

