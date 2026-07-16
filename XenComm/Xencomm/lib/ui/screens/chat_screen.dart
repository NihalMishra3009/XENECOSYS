import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../models/message_model.dart';
import '../../providers/app_providers.dart';
import '../../services/message_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String contactID;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactID,
    required this.contactName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _messageService = MessageService();
  final List<Message> _messages = [];
  String _selectedPriority = AppConstants.priorityNormal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    final messages = await _messageService.getConversation(currentUser.uniqueID, widget.contactID);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(widget.contactID, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text(AppConstants.noMessages))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSender = message.senderID == currentUser?.uniqueID;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: FutureBuilder<String>(
                          future: currentUser == null
                              ? Future.value(message.encryptedContent)
                              : _messageService.decryptMessage(
                                  message,
                                  currentUser.uniqueID,
                                  widget.contactID,
                                ),
                          builder: (context, snapshot) {
                            final text = snapshot.data ?? '...';
                            return Row(
                              mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isSender) _avatar(false),
                                if (!isSender) const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSender
                                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft: Radius.circular(isSender ? 18 : 4),
                                        bottomRight: Radius.circular(isSender ? 4 : 18),
                                      ),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          text,
                                          style: TextStyle(
                                            color: isSender
                                                ? (Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.black
                                                    : Colors.white)
                                                : null,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          message.timestamp.toLocal().toString().substring(11, 16),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSender
                                                ? (Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.black54
                                                    : Colors.white70)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSender) const SizedBox(width: 8),
                                if (isSender) _avatar(true),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(16),
                  items: const [
                    AppConstants.priorityNormal,
                    AppConstants.priorityMedical,
                    AppConstants.priorityEmergency,
                  ].map((priority) => DropdownMenuItem(value: priority, child: Text(priority))).toList(),
                  onChanged: (value) => setState(() => _selectedPriority = value ?? AppConstants.priorityNormal),
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: AppConstants.typeMessage,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _loading ? null : _handleSendMessage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(AppConstants.send),
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

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    final currentUser = ref.read(currentUserProvider);
    if (text.isEmpty || currentUser == null) return;
    setState(() => _loading = true);
    try {
      await _messageService.sendMessage(
        senderID: currentUser.uniqueID,
        receiverID: widget.contactID,
        content: text,
        priority: _selectedPriority,
      );
      _messageController.clear();
      await _loadMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.messageQueued)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppConstants.sendFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

Widget _avatar(bool isSender) {
  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      color: isSender ? Colors.black : Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
    child: Icon(
      isSender ? Icons.person : Icons.person_outline,
      size: 16,
      color: isSender ? Colors.white : Colors.black54,
    ),
  );
}
