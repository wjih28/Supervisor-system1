import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class ChatContact {
  /// معرّف المحادثة (chat_id) — يكون null إذا لم يُنشأ صف في جدول chats بعد
  int? id;

  /// معرّف المجموعة (group_id) — مفتاح الاختيار الثابت لكل عنصر
  final int groupId;

  /// اسم قائد الفريق
  final String name;

  /// اسم المشروع (group_name)
  final String projectName;
  String lastMessage;
  String time;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatContact({
    this.id,
    required this.groupId,
    required this.name,
    required this.projectName,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.messages,
  });
}

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  /// حالة الرسالة من العمود message_status: sent / delivered / read (لرسائل المشرف).
  final String? status;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    this.status,
  });
}

/// Controller لإدارة المحادثات
class ChatsController extends ChangeNotifier {
  bool _isLoading = true;
  List<ChatContact> _chats = [];
  ChatContact? _selectedChat;
  StreamSubscription<List<Map<String, dynamic>>>? _msgSub;

  bool get isLoading => _isLoading;
  List<ChatContact> get chats => _chats;
  ChatContact? get selectedChat => _selectedChat;

  /// تنسيق وقت الرسالة (HH:mm) من تاريخ ISO
  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// تحميل المحادثات من قاعدة البيانات
  Future<void> loadChats(
      {required int supervisorId, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // المصدر الأساسي للقائمة: المجموعات التي يشرف عليها المشرف (كل واحدة لها قائد فريق)
      final groups = await SupabaseService.getGroupsBySupervisor(supervisorId);

      // المحادثات الموجودة مفهرسة حسب معرّف المجموعة لمراكبتها على القائمة
      final rawChats = await SupabaseService.getSupervisorChats(supervisorId);
      final Map<int, Map<String, dynamic>> chatByGroup = {
        for (final c in rawChats)
          if (c['id_group'] != null) c['id_group'] as int: c
      };

      final List<ChatContact> loaded = [];

      for (final group in groups) {
        final groupId = group.id;
        if (groupId == null) continue;

        final existing = chatByGroup[groupId];
        int? chatId;
        String lastMessage = '';
        String time = '';
        List<ChatMessage> messages = [];

        if (existing != null) {
          chatId = existing['chat_id'] as int;
          final messagesRaw = await SupabaseService.getChatMessages(chatId);
          messages = messagesRaw
              .map((m) => ChatMessage(
                    text: m['message_text'] ?? '',
                    time: _formatTime(m['created_at']?.toString()),
                    isMe: m['sender_role'] == 'supervisor',
                    status: m['message_status']?.toString(),
                  ))
              .toList();
          lastMessage = existing['last_message']?.toString() ?? '';
          time = _formatTime(existing['last_message_time']?.toString());
        }

        final leaderName = (group.leaderName != null &&
                group.leaderName!.trim().isNotEmpty)
            ? group.leaderName!
            : group.name;

        loaded.add(ChatContact(
          id: chatId,
          groupId: groupId,
          name: leaderName,
          projectName: group.name,
          lastMessage: lastMessage,
          time: time,
          messages: messages,
        ));
      }

      _chats = loaded;
      _selectedChat = _chats.isNotEmpty ? _chats.first : null;
      _subscribeMessages();
    } catch (e) {
      debugPrint('خطأ في تحميل المحادثات: $e');
      _chats = [];
      _selectedChat = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// اختيار محادثة عبر معرّف المجموعة (groupId)
  void selectChat(int? groupId) {
    if (groupId == null) {
      _selectedChat = null;
    } else {
      _selectedChat = _chats.firstWhere((c) => c.groupId == groupId);
    }
    _subscribeMessages();
    notifyListeners();
  }

  /// الاشتراك اللحظي في رسائل المحادثة المختارة (تظهر الرسائل الجديدة فوراً).
  void _subscribeMessages() {
    _msgSub?.cancel();
    _msgSub = null;
    final chat = _selectedChat;
    if (chat?.id == null) return;
    _msgSub = SupabaseService.getMessagesStream(chat!.id!).listen((rows) {
      chat.messages
        ..clear()
        ..addAll(rows.map((m) => ChatMessage(
              text: m['message_text'] ?? '',
              time: _formatTime(m['created_at']?.toString()),
              isMe: m['sender_role'] == 'supervisor',
              status: m['message_status']?.toString(),
            )));
      if (rows.isNotEmpty) {
        final last = rows.last;
        chat.lastMessage = last['message_text']?.toString() ?? chat.lastMessage;
        chat.time = _formatTime(last['created_at']?.toString());
      }
      notifyListeners();
    });
  }

  /// إرسال رسالة وحفظها في قاعدة البيانات
  Future<bool> sendMessage({
    required String text,
    required int supervisorId,
    bool isGuest = false,
  }) async {
    if (text.trim().isEmpty || _selectedChat == null) return false;

    final now = _formatTime(DateTime.now().toIso8601String());

    // عرض فوري في الواجهة + تحديث معاينة العنصر
    _selectedChat!.messages.add(
      ChatMessage(text: text, time: now, isMe: true, status: 'sent'),
    );
    _selectedChat!.lastMessage = text;
    _selectedChat!.time = now;
    notifyListeners();

    if (isGuest) return true;

    // إنشاء صف المحادثة كسولاً عند أول رسالة
    var chatId = _selectedChat!.id;
    if (chatId == null) {
      chatId = await SupabaseService.getOrCreateChat(
        supervisorId: supervisorId,
        groupId: _selectedChat!.groupId,
      );
      if (chatId == null) return false;
      _selectedChat!.id = chatId;
      _subscribeMessages(); // المحادثة أُنشئت الآن — ابدأ بثّ رسائلها
    }

    return SupabaseService.sendMessage(
      chatId,
      text,
      'supervisor',
      senderId: supervisorId,
    );
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
}
