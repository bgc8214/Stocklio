import 'package:flutter/material.dart';
import '../models/investment_journal.dart';
import '../services/database_service.dart';
import 'journal_edit_screen.dart';
import 'journal_detail_screen.dart';
import 'package:intl/intl.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final DatabaseService _db = DatabaseService();
  List<InvestmentJournal> _journals = [];
  bool _isLoading = true;
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    try {
      final journals = _searchQuery.isEmpty
          ? await _db.getAllJournals()
          : await _db.searchJournals(_searchQuery);
      setState(() {
        _journals = journals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일지 불러오기 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteJournal(int id) async {
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
      await _db.deleteJournal(id);
      _loadJournals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일지가 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 일지'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: JournalSearchDelegate(_db, _loadJournals),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '작성된 일지가 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '투자 생각을 기록해보세요',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _journals.length,
                  itemBuilder: (context, index) {
                    final journal = _journals[index];
                    return _buildJournalCard(journal);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JournalEditScreen(),
            ),
          );
          if (result == true) {
            _loadJournals();
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('일지 작성'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildJournalCard(InvestmentJournal journal) {
    final dateFormat = DateFormat('yyyy.MM.dd (E)', 'ko_KR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalDetailScreen(journal: journal),
            ),
          );
          if (result == true) {
            _loadJournals();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 감정 이모지
                  Text(
                    journal.moodEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  // 제목
                  Expanded(
                    child: Text(
                      journal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteJournal(journal.id!),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 날짜
              Text(
                dateFormat.format(journal.date),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              // 내용 미리보기
              Text(
                journal.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // 태그
              if (journal.tags != null && journal.tags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: journal.tags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 검색 Delegate
class JournalSearchDelegate extends SearchDelegate<InvestmentJournal?> {
  final DatabaseService db;
  final VoidCallback onSearchComplete;

  JournalSearchDelegate(this.db, this.onSearchComplete);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('제목이나 내용을 검색하세요'),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<InvestmentJournal>>(
      future: db.searchJournals(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('검색 결과가 없습니다'),
          );
        }

        final journals = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final journal = journals[index];
            final dateFormat = DateFormat('yyyy.MM.dd (E)', 'ko_KR');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Text(
                  journal.moodEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(journal.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateFormat.format(journal.date)),
                    const SizedBox(height: 4),
                    Text(
                      journal.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                onTap: () {
                  close(context, journal);
                  // 상세 화면으로 이동 로직 추가 가능
                },
              ),
            );
          },
        );
      },
    );
  }
}
