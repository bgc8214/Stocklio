/// 투자 일지 모델
class InvestmentJournal {
  final int? id;
  final DateTime date;
  final String title;
  final String content;
  final String? mood; // 감정 태그: 'happy', 'anxious', 'satisfied', 'regret'
  final List<String>? tags; // 태그 (예: ['배당', '수익실현', '손절'])
  final DateTime createdAt;

  InvestmentJournal({
    this.id,
    required this.date,
    required this.title,
    required this.content,
    this.mood,
    this.tags,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory InvestmentJournal.fromMap(Map<String, dynamic> map) {
    return InvestmentJournal(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      content: map['content'] as String,
      mood: map['mood'] as String?,
      tags: (map['tags'] as String?)?.split(','),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags?.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 감정 이모지 반환
  String get moodEmoji {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'anxious':
        return '😰';
      case 'satisfied':
        return '😌';
      case 'regret':
        return '😔';
      default:
        return '📝';
    }
  }

  /// 감정 레이블 반환
  String get moodLabel {
    switch (mood) {
      case 'happy':
        return '기쁨';
      case 'anxious':
        return '불안';
      case 'satisfied':
        return '만족';
      case 'regret':
        return '후회';
      default:
        return '중립';
    }
  }
}
