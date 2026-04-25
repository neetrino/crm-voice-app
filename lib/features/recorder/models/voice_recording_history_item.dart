class VoiceRecordingHistoryItem {
  const VoiceRecordingHistoryItem({
    required this.leadId,
    required this.durationSec,
    this.recordingId,
    this.createdAt,
    this.audioPath,
    this.mimeType,
    this.centerId,
    this.centerName,
  });

  final String leadId;
  final String? recordingId;
  final DateTime? createdAt;
  final int durationSec;
  final String? audioPath;
  final String? mimeType;
  final String? centerId;
  final String? centerName;

  bool get hasPlayableAudio => audioPath != null && audioPath!.isNotEmpty;

  factory VoiceRecordingHistoryItem.fromJson(Map<String, dynamic> json) {
    final center = _mapValue(json['center']) ?? _mapValue(json['branch']);
    final attachment = _mapValue(json['attachment']) ??
        _mapValue(json['voiceAttachment']) ??
        _mapValue(json['recording']);
    final r2Key = _firstString([
      json['r2Key'],
      attachment?['r2Key'],
      _mapValue(json['audio'])?['r2Key'],
    ]);
    return VoiceRecordingHistoryItem(
      leadId: _stringValue(json['leadId']) ?? _stringValue(json['id']) ?? '',
      recordingId:
          _stringValue(json['recordingId']) ?? _stringValue(attachment?['id']),
      createdAt: _dateValue(
        json['createdAt'] ??
            json['date'] ??
            json['recordedAt'] ??
            attachment?['createdAt'],
      ),
      durationSec: _durationValue(
        json['durationSec'] ??
            json['durationSeconds'] ??
            json['duration'] ??
            attachment?['durationSec'],
      ),
      audioPath: _firstString([
            json['audioPath'],
            attachment?['audioPath'],
            json['audioUrl'],
            json['recordingUrl'],
            json['fileUrl'],
            json['url'],
            _mapValue(json['audio'])?['url'],
          ]) ??
          _storagePathFromR2Key(r2Key),
      mimeType: _firstString([
        json['mimeType'],
        attachment?['mimeType'],
        _mapValue(json['audio'])?['mimeType'],
      ]),
      centerId: _stringValue(json['centerId']) ??
          _stringValue(center?['id']) ??
          _stringValue(attachment?['centerId']),
      centerName: _stringValue(json['centerName']) ??
          _stringValue(center?['name']) ??
          _stringValue(center?['title']),
    );
  }

  @Deprecated('Use audioPath instead.')
  String? get audioUrl => audioPath;

  VoiceRecordingHistoryItem copyWith({
    String? centerId,
    String? centerName,
    String? audioPath,
    String? mimeType,
  }) {
    return VoiceRecordingHistoryItem(
      leadId: leadId,
      recordingId: recordingId,
      createdAt: createdAt,
      durationSec: durationSec,
      audioPath: audioPath ?? this.audioPath,
      mimeType: mimeType ?? this.mimeType,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
    );
  }
}

String? _storagePathFromR2Key(String? r2Key) {
  if (r2Key == null || r2Key.isEmpty) return null;
  return '/storage/file/${Uri.encodeComponent(r2Key)}';
}

Map<String, dynamic>? _mapValue(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

String? _stringValue(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String? _firstString(List<Object?> values) {
  for (final value in values) {
    final text = _stringValue(value);
    if (text != null) return text;
  }
  return null;
}

DateTime? _dateValue(Object? value) {
  final text = _stringValue(value);
  return text == null ? null : DateTime.tryParse(text);
}

int _durationValue(Object? value) {
  if (value is num) return value.round();
  final text = _stringValue(value);
  if (text == null) return 0;
  return int.tryParse(text) ?? _colonDuration(text);
}

int _colonDuration(String value) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length == 2 && parts.every((part) => part != null)) {
    return (parts[0]! * 60) + parts[1]!;
  }
  if (parts.length == 3 && parts.every((part) => part != null)) {
    return (parts[0]! * 3600) + (parts[1]! * 60) + parts[2]!;
  }
  return 0;
}
