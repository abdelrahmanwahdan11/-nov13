import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voxa/controllers/downloads_controller.dart';
import 'package:voxa/data/dummy_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DownloadsController loads persisted entries', () async {
    final sample = DownloadEntry(
      id: 'audio_persisted',
      title: 'Persisted Story',
      imageUrl: 'https://example.com/image.jpg',
      durationSec: 240,
      progress: 1.0,
      isCompleted: true,
      isPaused: false,
      queuedAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ).toJson();

    SharedPreferences.setMockInitialValues({
      'downloads': [jsonEncode(sample)],
    });

    final controller = await DownloadsController.load();
    expect(controller.completed.length, 1);

    await controller.clearCompleted();
    expect(controller.entries, isEmpty);

    controller.dispose();
  });

  test('startDownload registers new entry', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = await DownloadsController.load();
    final item = DummyData.audioItems.first;

    controller.startDownload(item);

    expect(controller.entryFor(item.id), isNotNull);

    controller.dispose();
  });
}
