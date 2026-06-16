import 'package:flutter/material.dart';
import '../../controllers/supervisor/chats_controller.dart';
import '../widgets/desktop_layout.dart';

class ChatsView extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const ChatsView({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final ChatsController _controller = ChatsController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
    _controller.loadChats(
        supervisorId: widget.supervisorId, isGuest: widget.isGuest);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final success = await _controller.sendMessage(
      text: text,
      supervisorId: widget.supervisorId,
      isGuest: widget.isGuest,
    );

    if (widget.isGuest && success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذه المحادثة عرضية ولا تُرسل فعلياً')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return DesktopLayout(
      selectedIndex: 2,
      supervisorId: widget.supervisorId,
      supervisorName: widget.supervisorName,
      isGuest: widget.isGuest,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (isDesktop || _controller.selectedChat == null)
                              Expanded(
                                flex: isDesktop ? 1 : 1,
                                child: _buildChatList(),
                              ),
                            if (isDesktop)
                              Container(width: 1, color: Colors.grey.shade200),
                            if (isDesktop || _controller.selectedChat != null)
                              Expanded(
                                flex: isDesktop ? 2 : 1,
                                child: _buildChatWindow(isDesktop),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الدردشات',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 4),
            Text(
              'تواصل مع الطلاب ومتابعة أبحاثهم',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: ListView.separated(
            itemCount: _controller.chats.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final chat = _controller.chats[index];
              final isSelected =
                  _controller.selectedChat?.groupId == chat.groupId;

              return InkWell(
                onTap: () => _controller.selectChat(chat.groupId),
                child: Container(
                  color:
                      isSelected ? const Color(0xFFF0F4FF) : Colors.transparent,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(Icons.person, color: Color(0xFF2D62ED)),
                      ),

                      const SizedBox(width: 12),

                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  chat.time,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat.projectName,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFFA0AEC0)),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (chat.lastMessage.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                chat.lastMessage,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Badge
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Color(0xFF2D62ED), shape: BoxShape.circle),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        const SizedBox(width: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatWindow(bool isDesktop) {
    if (_controller.selectedChat == null) {
      return Center(
        child: Text('اختر محادثة للبدء',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      );
    }

    final chat = _controller.selectedChat!;

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                  onPressed: () => _controller.selectChat(null),
                ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(Icons.person, color: Color(0xFF2D62ED)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(chat.projectName,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages.reversed.toList()[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D62ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    // In the screenshot:
    // Student messages are Blue and on the Right.
    // Supervisor (isMe) messages are White and on the Left.

    final align = msg.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bgColor = msg.isMe ? Colors.white : const Color(0xFF2D62ED);
    final textColor = msg.isMe ? const Color(0xFF2D3748) : Colors.white;
    final timeColor =
        msg.isMe ? Colors.grey.shade500 : Colors.white.withAlpha(200);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: msg.isMe ? Border.all(color: Colors.grey.shade200) : null,
              boxShadow: msg.isMe
                  ? [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4)]
                  : null,
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(color: textColor, fontSize: 14),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (msg.isMe) ...[
                      _buildStatusTick(msg.status),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      msg.time,
                      style: TextStyle(color: timeColor, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// علامة حالة رسالة المشرف: ✓ مرسلة، ✓✓ مُسلّمة (رمادي)، ✓✓ مقروءة (أزرق).
  Widget _buildStatusTick(String? status) {
    final isRead = status == 'read';
    final icon = status == 'read' || status == 'delivered'
        ? Icons.done_all
        : Icons.done;
    final color =
        isRead ? const Color(0xFF34B7F1) : Colors.grey.shade500;
    return Icon(icon, size: 14, color: color);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
