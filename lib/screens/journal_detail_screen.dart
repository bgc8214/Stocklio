import 'package:flutter/material.dart';
import '../models/investment_journal.dart';
import '../services/database_service.dart';
import 'journal_edit_screen.dart';
import 'package:intl/intl.dart';

class JournalDetailScreen extends StatefulWidget {
  final InvestmentJournal journal;

  const JournalDetailScreen({super.key, required this.journal});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final DatabaseService _db = DatabaseService();
  late InvestmentJournal _journal;

  @override
  void initState() {
    super.initState();
    _journal = widget.journal;
  }

  Future<void> _editJournal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditScreen(journal: _journal),
      ),
    );

    if (result == true) {
      // 수정된 일지 다시 불러오기
      final updatedJournal = await _db.getJournalById(_journal.id!);
      if (updatedJournal != null) {
        setState(() {
          _journal = updatedJournal;
        });
      }
    }
  }

  Future<void> _deleteJournal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('이 일지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteJournal(_journal.id!);
      if (mounted) {
        Navigator.pop(context, true); // 목록 화면으로 돌아가기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일지가 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');
    final createdFormat = DateFormat('yyyy.MM.dd HH:mm', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('일지 상세'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editJournal,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteJournal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 날짜
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Text(
                    dateFormat.format(_journal.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 감정
          if (_journal.mood != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      _journal.moodEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _journal.moodLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 제목
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '제목',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _journal.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 내용
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내용',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _journal.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 태그
          if (_journal.tags != null && _journal.tags!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '태그',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _journal.tags!.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 작성 일시
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '작성일: ${createdFormat.format(_journal.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
