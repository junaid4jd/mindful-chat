import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/screens/dashboard/pages/chatbot/chat_screen.dart';

class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  List<ChatMessage> _chatHistory = [];

  Future<void> _openChat(BuildContext context) async {
    final updated = await Navigator.push<List<ChatMessage>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialMessages: _chatHistory,
        ),
      ),
    );
    // If user popped with an updated list, save it
    if (updated != null) {
      _chatHistory = updated;
      notifyListeners();
    }
  }

  void setIndex(int index, BuildContext context) {
    if(index == 1) {
      _openChat(context);
    }
    _currentIndex = index;
    notifyListeners();
  }
}