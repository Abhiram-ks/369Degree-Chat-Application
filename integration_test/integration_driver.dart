import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';
import 'package:flutter_driver/driver_extension.dart';

Future<void> main() {
  enableFlutterDriverExtension();
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        debugPrint('Start performance data captured');
        debugPrint('----------------------------------------');
        debugPrint('Performance Data Captured');
        debugPrint('----------------------------------------');
        debugPrint('Start processing performance data');

        //! Report keys to process
        debugPrint('Report keys to process');
        debugPrint('----------------------------------------');
        final reportKeys = [
          'message_flow_performance',
          'database_performance',
          'reconnection_performance',
        ];

        for (final key in reportKeys) {
          if (data.containsKey(key)) {
            try {
              debugPrint('Processing: $key');

              final timeline = driver.Timeline.fromJson(
                data[key] as Map<String, dynamic>,
              );

              final summary = driver.TimelineSummary.summarize(timeline);

              await summary.writeTimelineToFile(
                key,
                pretty: true,
                includeSummary: true,
              );

              debugPrint('Timeline: build/$key.timeline.json');
              debugPrint('Summary: build/$key.timeline_summary.json');
              debugPrint('----------------------------------------');
            } catch (e) {
              debugPrint('Error: $e');
            }
          }
        }

        debugPrint('----------------------------------------');
        debugPrint('Performance Analysis Complete');
        debugPrint('----------------------------------------');
        debugPrint('Files saved in build/ directory');
        debugPrint('----------------------------------------');
        debugPrint('View timeline in Chrome:');
        debugPrint('1. Open chrome://tracing');
        debugPrint('2. Load .timeline.json files');
        debugPrint('----------------------------------------');
      }
    },
  );
}

