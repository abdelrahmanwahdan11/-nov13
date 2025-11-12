class RecordingClip {
  RecordingClip({
    required this.id,
    required this.duration,
    required this.waveform,
    required this.createdAt,
    this.filePath,
  });

  final String id;
  final Duration duration;
  final List<double> waveform;
  final DateTime createdAt;
  final String? filePath;

  String get friendlyLabel {
    if (id.length <= 4) {
      return '#$id';
    }
    return '#${id.substring(id.length - 4)}';
  }
}
