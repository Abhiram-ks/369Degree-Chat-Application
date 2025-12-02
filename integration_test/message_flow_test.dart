import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webchat/api/socket/websocket_service.dart';
import 'package:webchat/core/di/di.dart' as di;
import 'package:webchat/src/data/datasource/local/database_helper.dart';
import 'package:webchat/src/data/datasource/local/message_local_datasource.dart';
import 'package:webchat/src/data/model/message_model.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// ============================================
/// INTEGRATION TEST: Message Flow
/// ============================================

void main() {
  //! Initialize integration test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Message Flow Integration Tests', () {
    // Services needed for testing
    late WebSocketService webSocketService;
    late MessageLocalDataSource messageLocalDataSource;
    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await di.init();
      webSocketService = di.sl<WebSocketService>();
      messageLocalDataSource = MessageLocalDataSource(
        dbHelper: DatabaseHelper.instance,
      );
    });

    tearDownAll(() async {
      try {
        await webSocketService.disconnect();
        messageLocalDataSource.dispose();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Cleanup warning: $e');
      }
    });

    // ═══════════════════════════════════════════════════════════
    // TEST 1: Complete Message Flow (Main Integration Test)
    // ═══════════════════════════════════════════════════════════
    
    testWidgets(
      'Complete Message Flow: Connect → Send → Receive → Save → Offline',
      (WidgetTester tester) async {
            debugPrint('----------------------------------------');
            debugPrint('Step 1: Testing core integration (WebSocket + Database)...');
            debugPrint('Setup complete');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 2: Connect WebSocket
            // ─────────────────────────────────────────────────────────
            debugPrint('----------------------------------------');
            debugPrint('Step 2: Connecting to WebSocket...');
            debugPrint('----------------------------------------');
            await webSocketService.connect();
            await tester.pump(const Duration(seconds: 3));
            
            expect(webSocketService.isConnected, isTrue);
            expect(webSocketService.status, WebSocketConnectionStatus.connected);
            debugPrint('✅ WebSocket connected');

            // ─────────────────────────────────────────────────────────
            // STEP 3: Send Message
            // ─────────────────────────────────────────────────────────
            const testMessage = 'Integration Test Message';
            const testUserId = 1;
            
            debugPrint('Step 3: Sending message...');
            debugPrint('----------------------------------------');
            webSocketService.sendMessage(testMessage, userId: testUserId);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('Message sent');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 4: Save to Database
            // ─────────────────────────────────────────────────────────
            debugPrint('Step 4: Saving to database...');
            debugPrint('----------------------------------------');
            final message = MessageModel(
              userId: testUserId,
              message: testMessage,
              date: DateTime.now(),
              isCurrentUser: true,
              status: MessageStatus.sent,
            );

            final messageId = await messageLocalDataSource.storeMessage(message);

            expect(messageId, greaterThan(0));
            debugPrint('Message saved (ID: $messageId)');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 5: Verify Database Storage
            // ─────────────────────────────────────────────────────────
            debugPrint('Step 5: Verifying database...');
            debugPrint('----------------------------------------');
            final messages = await messageLocalDataSource.getMessagesByUserId(testUserId);

            expect(messages, isNotEmpty);
            expect(messages.any((m) => m.message == testMessage), isTrue);
            debugPrint('Message verified in database');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 6: Test Offline Access
            // ─────────────────────────────────────────────────────────
            debugPrint('Step 6: Testing offline access...');
            debugPrint('----------------------------------------');
            await webSocketService.disconnect();
            await tester.pump(const Duration(seconds: 1));
            
            expect(webSocketService.isConnected, isFalse);
            debugPrint('Disconnected');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 7: Verify Offline Data Access
            // ─────────────────────────────────────────────────────────
            debugPrint('Step 7: Verifying offline data...');
            debugPrint('----------------------------------------');
            final offlineMessages = await messageLocalDataSource.getMessagesByUserId(testUserId);
            
            expect(offlineMessages, isNotEmpty);
            expect(offlineMessages.any((m) => m.message == testMessage), isTrue);
            debugPrint('Offline data accessible');
            debugPrint('----------------------------------------');

            // ─────────────────────────────────────────────────────────
            // STEP 8: Test Reconnection
            // ─────────────────────────────────────────────────────────
            debugPrint('Step 8: Testing reconnection...');
            debugPrint('----------------------------------------');
            await webSocketService.connect();
            await tester.pump(const Duration(seconds: 3));
            
            expect(webSocketService.isConnected, isTrue);
            debugPrint('Reconnected successfully');
            debugPrint('----------------------------------------');

        debugPrint('All steps completed!');
        debugPrint('----------------------------------------');
        await tester.pumpAndSettle();
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    // ═══════════════════════════════════════════════════════════
    // TEST 2: Database Persistence
    // ═══════════════════════════════════════════════════════════
    testWidgets(
      'Database Persistence Test',
      (WidgetTester tester) async {
        const userId = 99; 
            
            final message1 = MessageModel(
              userId: userId,
              message: 'Test message 1',
              date: DateTime.now(),
              isCurrentUser: true,
              status: MessageStatus.sent,
            );
            
            final message2 = MessageModel(
              userId: userId,
              message: 'Test message 2',
              date: DateTime.now(),
              isCurrentUser: false,
              status: MessageStatus.delivered,
            );

            await messageLocalDataSource.storeMessage(message1);
            await messageLocalDataSource.storeMessage(message2);

            final messages = await messageLocalDataSource.getMessagesByUserId(userId);
            
            expect(messages.length, greaterThanOrEqualTo(2));
            expect(messages.any((m) => m.message == 'Test message 1'), isTrue);
            expect(messages.any((m) => m.message == 'Test message 2'), isTrue);

        debugPrint('Database persistence verified');
        debugPrint('----------------------------------------');
        await tester.pumpAndSettle();
      },
    );

    // ═══════════════════════════════════════════════════════════
    // TEST 3: WebSocket Reconnection
    // ═══════════════════════════════════════════════════════════

    testWidgets(
      'WebSocket Reconnection Test',
      (WidgetTester tester) async {
            await webSocketService.connect();
            await tester.pump(const Duration(seconds: 3));
            
            expect(webSocketService.isConnected, isTrue);

            await webSocketService.disconnect();
            await tester.pump(const Duration(seconds: 1));
            
            expect(webSocketService.isConnected, isFalse);

            await webSocketService.connect();
            await tester.pump(const Duration(seconds: 3));

            expect(webSocketService.isConnected, isTrue);

        debugPrint('Reconnection successful');
        debugPrint('----------------------------------------');
        await tester.pumpAndSettle();
      },
    );
  });
}

