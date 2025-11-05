import 'package:flutter_test/flutter_test.dart';
import 'package:stocklio/models/investment_journal.dart';

void main() {
  group('InvestmentJournal 모델 테스트', () {
    test('fromMap으로 정상적으로 객체 생성', () {
      final map = {
        'id': 1,
        'date': '2025-01-15',
        'title': '첫 투자 일지',
        'content': '오늘 애플 주식을 매수했다.',
        'mood': 'happy',
        'tags': '성장주,기술주',
        'created_at': '2025-01-15T10:30:00.000',
      };

      final journal = InvestmentJournal.fromMap(map);

      expect(journal.id, 1);
      expect(journal.title, '첫 투자 일지');
      expect(journal.content, '오늘 애플 주식을 매수했다.');
      expect(journal.mood, 'happy');
      expect(journal.tags, ['성장주', '기술주']);
      expect(journal.date.year, 2025);
      expect(journal.date.month, 1);
      expect(journal.date.day, 15);
    });

    test('toMap으로 정상적으로 Map 변환', () {
      final journal = InvestmentJournal(
        id: 1,
        date: DateTime(2025, 1, 15),
        title: '첫 투자 일지',
        content: '오늘 애플 주식을 매수했다.',
        mood: 'happy',
        tags: ['성장주', '기술주'],
        createdAt: DateTime(2025, 1, 15, 10, 30),
      );

      final map = journal.toMap();

      expect(map['id'], 1);
      expect(map['title'], '첫 투자 일지');
      expect(map['content'], '오늘 애플 주식을 매수했다.');
      expect(map['mood'], 'happy');
      expect(map['tags'], '성장주,기술주');
      expect(map['date'], '2025-01-15');
    });

    test('감정 이모지가 올바르게 반환됨', () {
      final happyJournal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
        mood: 'happy',
      );

      expect(happyJournal.moodEmoji, '😊');

      final anxiousJournal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
        mood: 'anxious',
      );

      expect(anxiousJournal.moodEmoji, '😰');
    });

    test('감정 레이블이 올바르게 반환됨', () {
      final satisfiedJournal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
        mood: 'satisfied',
      );

      expect(satisfiedJournal.moodLabel, '만족');

      final regretJournal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
        mood: 'regret',
      );

      expect(regretJournal.moodLabel, '후회');
    });

    test('감정이 null일 때 기본값 반환', () {
      final journal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
      );

      expect(journal.moodEmoji, '📝');
      expect(journal.moodLabel, '중립');
    });

    test('태그가 null일 때 정상 처리', () {
      final journal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
      );

      final map = journal.toMap();
      expect(map['tags'], null);
    });

    test('빈 태그 리스트일 때 정상 처리', () {
      final journal = InvestmentJournal(
        date: DateTime.now(),
        title: '테스트',
        content: '내용',
        tags: [],
      );

      final map = journal.toMap();
      expect(map['tags'], '');
    });
  });
}
