import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/project_repository.dart';
import '../../repositories/project_repository_impl.dart';

class ChatsScreen extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const ChatsScreen({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];
  int? _selectedGroupId;
  List<ReviewComment> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ProjectRepository _projectRepository;

  @override
  void initState() {
    super.initState();

    _projectRepository = ProjectRepositoryImpl();

    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isGuest) {
        _groups = [
          ResearchGroup(
            id: 201,
            name: 'مجموعة النقاش التجريبية 1',
            currentStage: 'التخطيط',
            progress: 40,
          ),
          ResearchGroup(
            id: 202,
            name: 'مجموعة النقاش التجريبية 2',
            currentStage: 'المراجعة',
            progress: 65,
          ),
        ];
        if (_groups.isNotEmpty) {
          _selectChat(_groups[0].id!);
        }
      } else {
        _groups =
            await _projectRepository.getGroupsBySupervisor(widget.supervisorId);
        if (_groups.isNotEmpty) {
          _selectChat(_groups[0].id!);
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المحادثات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectChat(int groupId) async {
    setState(() {
      _selectedGroupId = groupId;
      _messages = [];
    });
    if (widget.isGuest) {
      _messages = [
        ReviewComment(
          id: 1,
          groupId: groupId,
          supervisorId: 0,
          comment: 'مرحباً! هذا الحوار التجريبي لعرض واجهة المحادثات.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        ReviewComment(
          id: 2,
          groupId: groupId,
          supervisorId: null,
          comment: 'شكراً لك، أريد رؤية حالة المشروع وكيفية التقدم.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ];
      setState(() {});
      _scrollToBottom();
    } else {
      _loadMessages(groupId);
    }
  }

  Future<void> _loadMessages(int groupId) async {
    try {
      _messages = await _projectRepository.getChatMessages(groupId);
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('خطأ في تحميل الرسائل: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedGroupId == null) {
      return;
    }

    final text = _messageController.text.trim();
    _messageController.clear();

    if (widget.isGuest) {
      setState(() {
        _messages.add(ReviewComment(
          groupId: _selectedGroupId,
          comment: text,
          supervisorId: widget.supervisorId,
          createdAt: DateTime.now(),
        ));
      });
      _scrollToBottom();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذه المحادثة عرضية ولا تُرسل فعلياً')),
      );
      return;
    }

    try {
      await _projectRepository.sendMessage(
          _selectedGroupId!, widget.supervisorId, text);
      _loadMessages(_selectedGroupId!);
    } catch (e) {
      debugPrint('خطأ في إرسال الرسالة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: _buildChatList()),
          const VerticalDivider(width: 1),
          Expanded(flex: 2, child: _buildChatWindow()),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final isSelected = _selectedGroupId == group.id;
        return ListTile(
          onTap: () => _selectChat(group.id!),
          selected: isSelected,
          selectedTileColor: Colors.blue.withValues(alpha: 0.1),
          title: Text(group.name,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: const Text('آخر رسالة...', style: TextStyle(fontSize: 12)),
        );
      },
    );
  }

  Widget _buildChatWindow() {
    if (_selectedGroupId == null) {
      return const Center(child: Text('اختر مجموعة للبدء'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg.supervisorId != null;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isMe ? const Color(0xFF2D62ED) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg.comment,
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                      hintText: 'اكتب رسالة...', border: OutlineInputBorder()),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2D62ED)),
                  onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }
}
