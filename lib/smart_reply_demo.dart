import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

class SmartReplyDemo extends StatefulWidget {
  const SmartReplyDemo({Key? key}) : super(key: key);

  @override
  State<SmartReplyDemo> createState() => _SmartReplyDemoState();
}

class _SmartReplyDemoState extends State<SmartReplyDemo> {
  final _inputTextController = TextEditingController();
  final _listViewController = ScrollController();
  final smartReply = SmartReply();

  List<Message> messages = [];
  List<String> replies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google ML Kit Smart Reply Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                controller: _listViewController,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemBuilder: (context, index) => MessageListItem(message: messages[index]),
                itemCount: messages.length,
              ),
            ),
          ),
          const Divider(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: replies.isNotEmpty ? 25.0 : 0.0,
            child: SmartReplies(
              onReplyTap: _onReplyTap,
              replies: replies,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputTextController,
                    decoration: const InputDecoration(
                      hintText: "Write message...",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _onMessageSent,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMessageSent() {
    _sendNewMessage();
    _showReplies();
  }

  void _onReplyTap(String reply) {
    _sendReply(reply);
  }

  void _sendNewMessage() {
    final messageText = _inputTextController.text;
    final message = Message(messageText, true);
    setState(() {
      messages.insert(0, message);
    });
    _scrollToBottom();
    _inputTextController.clear();

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    smartReply.addMessageToConversationFromRemoteUser(messageText, currentTimestamp, "1");
  }

  void _showReplies() async {
    final suggestedReplies = await smartReply.suggestReplies();
    if (suggestedReplies.status == SmartReplySuggestionResultStatus.success) {
      setState(() {
        replies = suggestedReplies.suggestions;
      });
    }
  }

  void _sendReply(String reply) {
    final message = Message(reply, false);
    setState(() {
      messages.insert(0, message);
      replies.clear();
    });
    _scrollToBottom();

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    smartReply.addMessageToConversationFromLocalUser(reply, currentTimestamp);
  }

  void _scrollToBottom() {
    _listViewController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    _listViewController.dispose();
    super.dispose();
  }
}

class SmartReplies extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReplyTap;

  const SmartReplies({
    Key? key,
    required this.replies,
    required this.onReplyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: replies
          .map((reply) => ActionChip(
                label: Text(reply),
                onPressed: () => onReplyTap(reply),
              ))
          .toList(),
    );
  }
}

class MessageListItem extends StatelessWidget {
  final Message message;

  const MessageListItem({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Align(
        alignment: (message.isLocalUser ? Alignment.topRight : Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (message.isLocalUser ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isLocalUser;

  Message(this.text, this.isLocalUser);
}
