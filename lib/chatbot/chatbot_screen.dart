import 'package:genius_school/chatbot/chatbot_widgets.dart';
import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  final Map<String, dynamic> dashboardData;

  const ChatBotScreen({super.key, required this.dashboardData});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  List<dynamic> get homeworks => widget.dashboardData["homeworks"] ?? [];
  double get dues =>
      double.tryParse(widget.dashboardData["dues"].toString()) ?? 0;

  double get siblingDues =>
      double.tryParse(widget.dashboardData["sibling_dues"].toString()) ?? 0;

  double get fine =>
      double.tryParse(widget.dashboardData["fine"].toString()) ?? 0;

  int get payments =>
      int.tryParse(widget.dashboardData["payments"].toString()) ?? 0;

  String get paymentDate =>
      widget.dashboardData["payment_date"]?.toString() ?? "-";

  int get subjects =>
      int.tryParse(widget.dashboardData["subjects"].toString()) ?? 0;

  String get todayStatus =>
      widget.dashboardData["today_status"]?.toString() ?? "";

  Map<String, dynamic> get attendance =>
      widget.dashboardData["attendances"] ?? {};

  final List<Map<String, dynamic>> _messages = [
    {
      "message":
          "Hello 👋\nI'm your School Assistant.\nHow can I help you today?",
      "isUser": false,
      "type": "text",
    },
  ];

  final List<String> _suggestions = [
    "✨ Today",
    "💰 Fee",
    "📚 Homework",
    "📊 Attendance",
    "📚 Subjects",
  ];
  String _getMessageType(String message) {
    final text = message.toLowerCase().trim();

    if (text.contains("fee") ||
        text.contains("fees") ||
        text.contains("payment") ||
        text.contains("due") ||
        text.contains("paisa") ||
        text.contains("baki")) {
      return "fee";
    }

    if (text.contains("homework") ||
        text.contains("assignment") ||
        text.contains("hw")) {
      return "homework";
    }

    if (text.contains("attendance") ||
        text.contains("present") ||
        text.contains("absent") ||
        text.contains("leave") ||
        text.contains("hajri")) {
      return "attendance";
    }

    if (text.contains("today") || text.contains("aaj")) {
      return "today";
    }

    return "text";
  }
  // ================= BOT REPLY =================

  String _getBotReply(String message) {
    final text = message.toLowerCase().trim();

    // ================= GREETING =================

    if (text.contains("hello") ||
        text.contains("hi") ||
        text.contains("hey") ||
        text.contains("hii")) {
      return "Hello 👋\nHow can I help you today?";
    }

    // ================= FEE =================

    if (text.contains("fee") ||
        text.contains("fees") ||
        text.contains("payment") ||
        text.contains("due") ||
        text.contains("paisa")) {
      return """
💰 Fee Summary

💵 Due Fee: ₹${dues.toStringAsFixed(0)}
👨‍👩‍👧 Sibling Due: ₹${siblingDues.toStringAsFixed(0)}
⚠️ Fine: ₹${fine.toStringAsFixed(0)}

💳 Total Payments: $payments
📅 Last Payment: $paymentDate
""";
    }

    // ================= HOMEWORK =================

    if (text.contains("homework") ||
        text.contains("assignment") ||
        text.contains("hw")) {
      if (homeworks.isEmpty) {
        return "📚 No homework is available right now.";
      }

      return "📚 Here is your recent homework.";
    }

    // ================= ATTENDANCE =================

    if (text.contains("attendance") ||
        text.contains("present") ||
        text.contains("absent") ||
        text.contains("leave")) {
      final present = int.tryParse(attendance["present"].toString()) ?? 0;

      final absent = int.tryParse(attendance["absent"].toString()) ?? 0;

      final halfDay = int.tryParse(attendance["half_day"].toString()) ?? 0;

      final leave = int.tryParse(attendance["leave"].toString()) ?? 0;

      final workingDays =
          int.tryParse(attendance["working_days"].toString()) ?? 0;

      double percentage = 0;

      if (workingDays > 0) {
        percentage = (present / workingDays) * 100;
      }

      return """
📊 Attendance Summary

🟢 Present: $present
🔴 Absent: $absent
🟡 Half Day: $halfDay
🔵 Leave: $leave
📅 Working Days: $workingDays

🎯 Attendance: ${percentage.toStringAsFixed(1)}%
""";
    }

    // ================= TODAY =================

    if (text.contains("today") || text.contains("aaj")) {
      String attendanceText;

      if (todayStatus == "not_mark") {
        attendanceText = "🟠 Attendance not marked yet";
      } else {
        attendanceText = "🟢 Attendance: $todayStatus";
      }

      return """
☀️ Today's Update

$attendanceText

📚 Subjects: $subjects

💰 Fee Due: ₹${dues.toStringAsFixed(0)}

📝 Homework Available: ${homeworks.length}
""";
    }

    // ================= SUBJECT =================

    if (text.contains("subject")) {
      return """
📚 Subject Information

You have $subjects subjects.
""";
    }

    // ================= THANKS =================

    if (text.contains("thank")) {
      return "You're welcome 😊\nHappy to help!";
    }

    // ================= BYE =================

    if (text.contains("bye")) {
      return "Goodbye 👋\nHave a great day!";
    }

    // ================= UNKNOWN =================

    return """
🤔 Sorry, I didn't understand that.

You can ask me about:

✨ Today
💰 Fee
📚 Homework
📊 Attendance
📚 Subjects
""";
  }

  // ================= SEND MESSAGE =================

  void _sendMessage([String? quickMessage]) {
    final message = quickMessage ?? _controller.text.trim();

    if (message.isEmpty || _isTyping) return;

    // Remove emoji from quick suggestion
    final cleanMessage = message.replaceAll(RegExp(r'[^\w\s]'), '').trim();

    setState(() {
      _messages.add({"message": cleanMessage, "isUser": true, "type": "text"});

      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Small delay for natural chatbot feel
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        final messageType = _getMessageType(cleanMessage);

        _messages.add({
          "message": _getBotReply(cleanMessage),
          "isUser": false,
          "type": messageType,
        });

        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  // ================= SCROLL =================

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.indigo,
                size: 23,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "School Assistant",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1),
                Text(
                  "Online",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ================= MESSAGES =================
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];

                  final String type = message["type"] ?? "text";
                  final bool isUser = message["isUser"] ?? false;

                  // ================= SPECIAL CARDS =================

                  if (!isUser &&
                      (type == "fee" ||
                          type == "attendance" ||
                          type == "homework" ||
                          type == "today")) {
                    return ChatbotWidgets(
                      type: type,
                      attendance: attendance,
                      homeworks: homeworks,
                      todayStatus: todayStatus,
                      subjects: subjects,
                      dues: dues,
                      siblingDues: siblingDues,
                      fine: fine,
                      payments: payments,
                      paymentDate: paymentDate,
                    );
                  }

                  // ================= NORMAL MESSAGE =================

                  return _buildMessageBubble(message["message"], isUser);
                },
              ),
            ),

            // ================= TYPING =================
            if (_isTyping) _buildTypingIndicator(),

            // ================= QUICK OPTIONS =================
            _buildSuggestions(),

            // ================= INPUT =================
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ================= MESSAGE BUBBLE =================

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isUser ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  // ================= QUICK SUGGESTIONS =================

  Widget _buildSuggestions() {
    return Container(
      color: const Color(0xFFF5F7FB),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _suggestions.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _sendMessage(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigo.withOpacity(0.20)),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= TYPING INDICATOR =================

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.indigo,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Assistant is typing...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INPUT AREA =================

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ================= TEXT FIELD =================
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: "Ask something...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ================= SEND BUTTON =================
          Material(
            color: Colors.indigo,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _sendMessage(),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 21),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
