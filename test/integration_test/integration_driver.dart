import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';
import 'package:flutter_driver/driver_extension.dart';
/// Performance Profiling Driver for Integration Tests
/// 
/// This driver captures performance timelines and saves them to disk.
/// Results can be viewed in Chrome's tracing tool (chrome://tracing)
/// 
/// Run with:
/// flutter drive \
///   --driver=test_driver/integration_driver.dart \
///   --target=integration_test/message_flow_test.dart \
///   --profile
/// 
/// Results will be in build/ directory:
/// - message_flow_performance.timeline.json
/// - message_flow_performance.timeline_summary.json
Future<void> main() {
      enableFlutterDriverExtension();
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        print('');
        print('📊 ========================================');
        print('📊 Performance Data Captured');
        print('📊 ========================================');
        print('');

        // Process each timeline
        final reportKeys = [
          'message_flow_performance',
          'database_performance',
          'reconnection_performance',
        ];

        for (final key in reportKeys) {
          if (data.containsKey(key)) {
            try {
              print('📈 Processing: $key');

              final timeline = driver.Timeline.fromJson(
                data[key] as Map<String, dynamic>,
              );

              // Convert to TimelineSummary for easier analysis
              final summary = driver.TimelineSummary.summarize(timeline);

              // Save complete timeline (for chrome://tracing)
              // Save summary (human-readable metrics)
              await summary.writeTimelineToFile(
                key,
                pretty: true,
                includeSummary: true,
              );

              print('   ✅ Timeline: build/$key.timeline.json');
              print('   ✅ Summary: build/$key.timeline_summary.json');
              print('');
            } catch (e) {
              print('   ⚠️  Error: $e');
            }
          }
        }

        print('📊 ========================================');
        print('📊 Performance Analysis Complete');
        print('📊 ========================================');
        print('');
        print('📁 Files saved in build/ directory');
        print('');
        print('🌐 View timeline in Chrome:');
        print('   1. Open chrome://tracing');
        print('   2. Load .timeline.json files');
        print('');
        print('📈 Metrics include:');
        print('   • Frame build times');
        print('   • Missed frames');
        print('   • Rasterizer performance');
        print('');
      }
    },
  );
}

