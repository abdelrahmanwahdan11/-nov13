import 'package:flutter/material.dart';

class PublishState {
  PublishState({
    required this.title,
    required this.tags,
    required this.privacy,
    required this.coverUrl,
  });

  final String title;
  final List<String> tags;
  final String privacy;
  final String coverUrl;

  PublishState copyWith({
    String? title,
    List<String>? tags,
    String? privacy,
    String? coverUrl,
  }) {
    return PublishState(
      title: title ?? this.title,
      tags: tags ?? this.tags,
      privacy: privacy ?? this.privacy,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

class PublishController extends ValueNotifier<PublishState> {
  PublishController()
      : super(
          PublishState(
            title: '',
            tags: const [],
            privacy: 'public',
            coverUrl: '',
          ),
        );

  void setTitle(String value) {
    this.value = this.value.copyWith(title: value);
  }

  void setTags(List<String> tags) {
    value = value.copyWith(tags: tags);
  }

  void setPrivacy(String privacy) {
    value = value.copyWith(privacy: privacy);
  }

  void setCover(String cover) {
    value = value.copyWith(coverUrl: cover);
  }
}
