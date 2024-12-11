import 'package:flutter/material.dart';

class ChatMessage{
  final String message;
  final String user;
  final DateTime time;

  ChatMessage({required this.message, required this.user, required this.time});
}

class MessageProvider extends ChangeNotifier{

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<ChatMessage> getMessage(){
    return _messages;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void storeMessage(ChatMessage message){
    _messages.add(message);
    notifyListeners();
  }

  String getConversationContext() {
    return _messages
    .map((message) {
      if (message.user == "Gemini") {
        return message.message;
      } else {
        return "${message.user}: ${message.message}";
      }
    })
    .join("\n");
  }
}