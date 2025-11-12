import 'dart:math';

import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/audio_item.dart';
import '../models/community_event.dart';
import '../models/onboarding_guide.dart';
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

  static List<CommunityEvent> communityEvents = List<CommunityEvent>.generate(18, (index) {
    final random = Random(index * 17);
    final startOffset = random.nextInt(72) - 24;
    final duration = 30 + random.nextInt(75);
    return CommunityEvent(
      id: 'event_$index',
      title: 'Collab Lab ${String.fromCharCode(65 + index % 26)}',
      subtitle: index.isEven
          ? 'Layer immersive ambiences with fellow hosts.'
          : 'Trade mastering tricks live with the Voxa crew.',
      host: 'Studio ${index % 4 + 1}',
      startTime: DateTime.now().add(Duration(hours: startOffset)),
      duration: Duration(minutes: duration),
      tags: [
        if (index % 3 == 0) 'spatial',
        if (index % 2 == 0) 'story',
        if (index % 4 == 0) 'mixing',
        if (index % 5 == 0) 'growth',
        if (index % 2 == 1) 'community',
      ].where((tag) => tag.isNotEmpty).toSet().toList(),
      coverUrl: _images[index % _images.length],
      attending: 20 + random.nextInt(80),
      maxSlots: 120,
      category: ['Challenges', 'Studios', 'Meetups'][index % 3],
      isLive: startOffset <= 0 && startOffset.abs() * 60 < duration,
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

  static final List<OnboardingGuide> onboardingGuides = <OnboardingGuide>[
    const OnboardingGuide(
      id: 'story',
      title: 'Craft Your Story',
      subtitle: 'Set the vibe before you hit record.',
      description:
          'Pair your intro with the perfect waveform, mood tags, and artwork. We walk you through building a sonic identity that hooks listeners from the first beat.',
      imageUrl: _images[0],
      focusAreas: <String>['branding', 'waveform', 'mood'],
      actions: <String>['Open Editor', 'Browse Artwork'],
    ),
    const OnboardingGuide(
      id: 'record',
      title: 'Dial In Your Recording',
      subtitle: 'Master mic levels and calibration.',
      description:
          'Use the live meter, calibrate in seconds, and save rehearsal takes so you never lose a great moment. We highlight shortcuts that keep the session flowing.',
      imageUrl: _images[1],
      focusAreas: <String>['record', 'calibrate', 'levels'],
      actions: <String>['Open Recorder', 'View Labs'],
    ),
    const OnboardingGuide(
      id: 'publish',
      title: 'Publish Like a Pro',
      subtitle: 'Turn edits into a polished drop.',
      description:
          'Auto-generate cover art, add tags that boost discovery, and schedule your release. This walkthrough shows how to polish, preview, and share in minutes.',
      imageUrl: _images[2],
      focusAreas: <String>['publish', 'tags', 'schedule'],
      actions: <String>['Prepare Draft', 'Open Insights'],
    ),
  ];

  static final List<Achievement> achievements = <Achievement>[
    Achievement(
      id: 'streak_3',
      title: 'Spark the Streak',
      description: 'Create for three days in a row to warm up your momentum.',
      icon: Icons.local_fire_department_outlined,
      progress: 2,
      target: 3,
      xp: 120,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: true,
      highlight: 'One more day to ignite the streak!',
    ),
    Achievement(
      id: 'streak_7',
      title: 'Weekly Flame',
      description: 'Keep your publishing streak alive for a full week.',
      icon: Icons.auto_graph,
      progress: 6,
      target: 7,
      xp: 220,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: true,
      highlight: 'You are almost at the weekly milestone.',
    ),
    Achievement(
      id: 'streak_30',
      title: 'Orbit Runner',
      description: 'Share new sound every day for a month straight.',
      icon: Icons.public,
      progress: 18,
      target: 30,
      xp: 540,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: false,
    ),
    Achievement(
      id: 'labs_5',
      title: 'Lab Regular',
      description: 'Host or join five community labs to trade ideas.',
      icon: Icons.biotech_outlined,
      progress: 4,
      target: 5,
      xp: 160,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: true,
    ),
    Achievement(
      id: 'labs_15',
      title: 'Lab Architect',
      description: 'Keep exploring labs until you curate fifteen sessions.',
      icon: Icons.category_outlined,
      progress: 9,
      target: 15,
      xp: 320,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: false,
    ),
    Achievement(
      id: 'drops_12',
      title: 'Season Dropper',
      description: 'Publish twelve polished drops and keep the feed fresh.',
      icon: Icons.album_outlined,
      progress: 11,
      target: 12,
      xp: 280,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      isPinned: false,
      highlight: 'Your audience is loving the consistency.',
    ),
    Achievement(
      id: 'drops_30',
      title: 'Universe Curator',
      description: 'Release thirty episodes to build a signature universe.',
      icon: Icons.audiotrack,
      progress: 22,
      target: 30,
      xp: 520,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: false,
    ),
    Achievement(
      id: 'collab_6',
      title: 'Collab Catalyst',
      description: 'Co-create six pieces with the community spotlight.',
      icon: Icons.handshake_outlined,
      progress: 3,
      target: 6,
      xp: 190,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: false,
    ),
    Achievement(
      id: 'listener_1k',
      title: 'Thousand Ears',
      description: 'Reach one thousand unique listeners across your shows.',
      icon: Icons.headphones_outlined,
      progress: 720,
      target: 1000,
      xp: 400,
      isUnlocked: false,
      unlockedAt: null,
      isPinned: false,
    ),
    Achievement(
      id: 'save_250',
      title: 'Saved Favorite',
      description: 'Collect two hundred and fifty saves from loyal fans.',
      icon: Icons.bookmark_border,
      progress: 250,
      target: 250,
      xp: 260,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPinned: false,
    ),
  ];
}
