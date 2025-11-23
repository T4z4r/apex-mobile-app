import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/conversation.dart';

class ConversationsProvider extends ChangeNotifier {
  List<Conversation> conversations = [];
  bool loading = false;

  Future<void> fetchConversations(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getConversations(token);
      conversations = data.map<Conversation>((e) => Conversation.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Conversation?> getConversation(String token, int id) async {
    try {
      final data = await ApiService().getConversation(token, id);
      return Conversation.fromJson(data);
    } catch (e) {
      print('Error fetching conversation: $e');
      return null;
    }
  }

  Future<bool> createConversation(String token, Map<String, dynamic> conversationData) async {
    try {
      final data = await ApiService().createConversation(token, conversationData);
      final newConversation = Conversation.fromJson(data);
      conversations.add(newConversation);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating conversation: $e');
      return false;
    }
  }

  Future<bool> updateConversation(String token, int id, Map<String, dynamic> conversationData) async {
    try {
      final data = await ApiService().updateConversation(token, id, conversationData);
      final updatedConversation = Conversation.fromJson(data);
      final index = conversations.indexWhere((c) => c.id == id);
      if (index != -1) {
        conversations[index] = updatedConversation;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating conversation: $e');
      return false;
    }
  }

  Future<bool> leaveConversation(String token, int id) async {
    try {
      await ApiService().leaveConversation(token, id);
      conversations.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error leaving conversation: $e');
      return false;
    }
  }

  Future<List<Message>> getMessages(String token, int conversationId) async {
    try {
      final data = await ApiService().getMessages(token, conversationId);
      return data.map<Message>((e) => Message.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<bool> sendMessage(String token, int conversationId, Map<String, dynamic> messageData) async {
    try {
      await ApiService().sendMessage(token, conversationId, messageData);
      // Optionally refetch conversation to get updated messages
      await getConversation(token, conversationId);
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }
}