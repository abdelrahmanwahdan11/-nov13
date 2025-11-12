import 'dart:math';

import '../models/audio_item.dart';
import '../models/user.dart';

class DummyData {
  DummyData._();

  static const _images = [
    'https://images.unsplash.com/photo-1511379938547-c1f69419868d',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
  ];

  static List<AudioItem> audioItems = List<AudioItem>.generate(24, (index) {
    final random = Random(index * 33);
    return AudioItem(
      id: 'audio_$index',
      title: 'Dreamwave Session ${index + 1}',
      creator: 'Creator ${index + 1}',
      durationSec: 180 + random.nextInt(240),
      mood: ['Chill', 'Focus', 'Hype'][random.nextInt(3)],
      tags: ['ambient', 'story', 'tech'].sublist(0, 2),
      imageUrl: _images[index % _images.length],
      waveform: List<double>.generate(60, (i) => random.nextDouble()),
      likes: 300 + random.nextInt(500),
      plays: 2000 + random.nextInt(5000),
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(40))),
    );
  });

  static final user = User(
    id: 'user_1',
    name: 'Amina Vox',
    avatarUrl: _images.first,
    bio: 'Voice storyteller and audio engineer',
    stats: {
      'plays': 12000,
      'listeners': 4800,
      'episodes': 45,
    },
  );
}
