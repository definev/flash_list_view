import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

/// Example: [FlashSliverList] inside [CustomScrollView] with the typing
/// indicator as the last list item.
void main() {
  runApp(const FlashListViewExampleApp());
}

class FlashListViewExampleApp extends StatelessWidget {
  const FlashListViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashSliverList Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatMessage {
  const ChatMessage({required this.id, required this.text, required this.isMe});

  final String id;
  final String text;
  final bool isMe;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _typingIndicatorKey = 'typing-indicator';

  final _scrollController = ScrollController();
  final _flashSliverListController = FlashSliverListController();
  final _textController = TextEditingController();

  final List<ChatMessage> _messages = [
    const ChatMessage(id: '1', text: 'Hey! How are you?', isMe: false),
    const ChatMessage(id: '2', text: 'Doing great, thanks!', isMe: true),
    const ChatMessage(
      id: '3',
      text: 'Want to try FlashSliverList?',
      isMe: false,
    ),
    const ChatMessage(
      id: '4',
      text: 'Sure — typing indicator is the last list item.',
      isMe: true,
    ),
    const ChatMessage(
      id: '5',
      text: 'Scroll up to read older messages…',
      isMe: false,
    ),
    const ChatMessage(
      id: '6',
      text: 'The typing dots sit at the bottom.',
      isMe: true,
    ),
    const ChatMessage(id: '7', text: 'They scroll with the list.', isMe: false),
    const ChatMessage(
      id: '8',
      text: 'Just like a normal message row.',
      isMe: true,
    ),
  ];

  bool _isTyping = true;
  int _messageCounter = 9;

  int get _itemCount => _messages.length + (_isTyping ? 1 : 0);

  int get _typingIndicatorIndex => _messages.length;

  bool _isTypingIndicator(int index) =>
      _isTyping && index == _typingIndicatorIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final index = _isTyping ? _typingIndicatorIndex : _messages.length - 1;
    if (index < 0) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(id: '${_messageCounter++}', text: text, isMe: true),
      );
    });
    _textController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _toggleTyping() {
    setState(() => _isTyping = !_isTyping);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashSliverList Chat'),
        actions: [
          IconButton(
            tooltip: _isTyping
                ? 'Hide typing indicator'
                : 'Show typing indicator',
            onPressed: _toggleTyping,
            icon: Icon(
              _isTyping ? Icons.more_horiz : Icons.more_horiz_outlined,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  FlashListViewDelegate _buildListDelegate() {
    return FlashListViewDelegate(
      _buildItem,
      childCount: _itemCount,
      onItemKey: (index) {
        if (_isTypingIndicator(index)) return _typingIndicatorKey;
        return _messages[index].id;
      },
      keepPosition: true,
      keepPositionOffset: 0,
      firstItemAlign: FirstItemAlign.end,
      expandDirectToDownWhenFirstItemAlignToEnd: true,
      onItemHeight: (index) => _isTypingIndicator(index) ? 48 : 56,
      preferItemHeight: 56,
      onIsPermanent: (key) => key == _typingIndicatorKey,
      disableCacheItems: true,
    );
  }

  Widget _buildMessageList() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
          sliver: FlashSliverList(
            controller: _flashSliverListController,
            delegate: _buildListDelegate(),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (_isTypingIndicator(index)) {
      return const _TypingIndicator();
    }
    return _MessageBubble(message: _messages[index]);
  }

  Widget _buildInputBar() {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Type a message…',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = message.isMe
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foreground = message.isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isMe ? 18 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 18),
          ),
        ),
        child: Text(message.text, style: TextStyle(color: foreground)),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value * 3 - index).clamp(0.0, 1.0);
                final scale = 0.6 + (phase * 0.4);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.4 + phase * 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
