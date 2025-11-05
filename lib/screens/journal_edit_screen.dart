import 'package:flutter/material.dart';
import '../models/investment_journal.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class JournalEditScreen extends StatefulWidget {
  final InvestmentJournal? journal; // null이면 새로 작성, 있으면 수정

  const JournalEditScreen({super.key, this.journal});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<Map<String, String>> _moods = [
    {'value': 'happy', 'label': '기쁨', 'emoji': '😊'},
    {'value': 'satisfied', 'label': '만족', 'emoji': '😌'},
    {'value': 'anxious', 'label': '불안', 'emoji': '😰'},
    {'value': 'regret', 'label': '후회', 'emoji': '😔'},
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.journal != null) {
      // 수정 모드
      _titleController.text = widget.journal!.title;
      _contentController.text = widget.journal!.content;
      _selectedDate = widget.journal!.date;
      _selectedMood = widget.journal!.mood;
      if (widget.journal!.tags != null) {
        _tags.addAll(widget.journal!.tags!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final journal = InvestmentJournal(
        id: widget.journal?.id,
        date: _selectedDate,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mood: _selectedMood,
        tags: _tags.isEmpty ? null : _tags,
      );

      if (widget.journal == null) {
        // 새로 작성
        await _db.addJournal(journal);
      } else {
        // 수정
        await _db.updateJournal(journal);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.journal == null ? '일지가 저장되었습니다' : '일지가 수정되었습니다'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.journal != null;
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '일지 수정' : '일지 작성'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveJournal,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 날짜 선택
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: const Text('날짜'),
                subtitle: Text(dateFormat.format(_selectedDate)),
                onTap: _selectDate,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            const SizedBox(height: 16),

            // 감정 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 감정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mood['emoji']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 6),
                              Text(mood['label']!),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMood = selected ? mood['value'] : null;
                            });
                          },
                          selectedColor: Colors.deepPurple.withValues(alpha: 0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 제목
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '일지 제목을 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 내용
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                hintText: '투자 생각을 자유롭게 기록하세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 태그
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '태그',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: '태그 입력 (예: 배당, 수익실현)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addTag,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('추가'),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
