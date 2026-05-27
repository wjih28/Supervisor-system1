import 'package:flutter/material.dart';

class ChatContact {
  final int id;
  final String name;
  final String projectName;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatContact({
    required this.id,
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

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

/// Controller لإدارة المحادثات
class ChatsController extends ChangeNotifier {
  bool _isLoading = true;
  List<ChatContact> _chats = [];
  ChatContact? _selectedChat;

  bool get isLoading => _isLoading;
  List<ChatContact> get chats => _chats;
  ChatContact? get selectedChat => _selectedChat;

  /// تحميل المحادثات (بيانات وهمية متطابقة مع التصميم)
  Future<void> loadChats({required int supervisorId, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network

    _chats = [
      ChatContact(
        id: 1,
        name: 'أحمد محمد علي',
        projectName: 'تأثير التسويق الرقمي',
        lastMessage: 'شكراً دكتور، سنقوم بالتعديلات المطلوبة',
        time: '10:30 ص',
        unreadCount: 2,
        messages: [
          ChatMessage(text: 'السلام عليكم دكتور', time: '09:00 ص', isMe: false),
          ChatMessage(text: 'وعليكم السلام، تفضل', time: '09:05 ص', isMe: true),
          ChatMessage(text: 'أرسلت ملف المرحلة الأولى للمراجعة', time: '09:10 ص', isMe: false),
          ChatMessage(text: 'تمام، سأقوم بمراجعته وإرسال الملاحظات', time: '09:15 ص', isMe: true),
          ChatMessage(text: 'شكراً دكتور، في انتظار ملاحظاتكم', time: '09:20 ص', isMe: false),
          ChatMessage(text: 'تم مراجعة الملف، يحتاج بعض التعديلات في المقدمة', time: '09:30 ص', isMe: true),
        ],
      ),
      ChatContact(
        id: 2,
        name: 'فاطمة سعيد حسن',
        projectName: 'دور الذكاء الاصطناعي',
        lastMessage: 'متى يمكننا الاجتماع لمناقشة الخطة؟',
        time: 'أمس',
        unreadCount: 0,
        messages: [
          ChatMessage(text: 'دكتور، هل يمكننا الاجتماع غداً؟', time: '08:00 م', isMe: false),
          ChatMessage(text: 'نعم، غداً في العاشرة صباحاً مناسب', time: '08:15 م', isMe: true),
          ChatMessage(text: 'متى يمكننا الاجتماع لمناقشة الخطة؟', time: 'أمس', isMe: false),
        ],
      ),
      ChatContact(
        id: 3,
        name: 'خالد عبدالله محمد',
        projectName: 'إدارة الموارد البشرية',
        lastMessage: 'تم إرسال ملف المرحلة الثانية',
        time: 'الأحد',
        unreadCount: 1,
        messages: [
          ChatMessage(text: 'تم إرسال ملف المرحلة الثانية', time: 'الأحد', isMe: false),
        ],
      ),
      ChatContact(
        id: 4,
        name: 'نورا إبراهيم أحمد',
        projectName: 'استراتيجيات التجارة الإلكترونية',
        lastMessage: 'هل يمكن تمديد الموعد النهائي؟',
        time: 'السبت',
        unreadCount: 0,
        messages: [
          ChatMessage(text: 'هل يمكن تمديد الموعد النهائي؟', time: 'السبت', isMe: false),
        ],
      ),
    ];

    if (_chats.isNotEmpty) {
      _selectedChat = _chats[0];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// اختيار محادثة
  void selectChat(int? id) {
    if (id == null) {
      _selectedChat = null;
    } else {
      _selectedChat = _chats.firstWhere((c) => c.id == id);
    }
    notifyListeners();
  }

  /// إرسال رسالة
  Future<bool> sendMessage({
    required String text,
    required int supervisorId,
    bool isGuest = false,
  }) async {
    if (text.trim().isEmpty || _selectedChat == null) return false;

    _selectedChat!.messages.add(
      ChatMessage(
        text: text,
        time: 'الآن', // Placeholder for current time
        isMe: true,
      ),
    );
    notifyListeners();
    return true;
  }
}
