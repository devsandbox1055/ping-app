import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/partner_status.dart';

class ApiService {
  //CHANGE THIS URL TO YOUR AWS BACKEND
  static const String baseUrl = 'backend url';
  static const String wsUrl = 'backend url';

  WebSocketChannel? _channel;

  Future<User> createUser(String username, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      body: {'username': username, 'email': email},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }

  Future<void> pairUsers(String pairCode, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/pair?pair_code=$pairCode&user_id=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to pair users: ${response.statusCode}');
    }
  }

  Future<PartnerStatus> getPartnerStatus(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/partner-status/$userId'),
    );

    if (response.statusCode == 200) {
      return PartnerStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get partner status: ${response.statusCode}');
    }
  }

  void connectWebSocket(int userId) {
    _channel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws/$userId'));
  }

  void sendHeartbeat(String status) {
    if (_channel != null) {
      _channel!.sink.add(json.encode({'type': 'heartbeat', 'status': status}));
    }
  }

  void sendTypingIndicator(bool isTyping) {
    if (_channel != null) {
      _channel!.sink.add(
        json.encode({'type': 'typing', 'is_typing': isTyping}),
      );
    }
  }

  Stream get messages {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }
    return _channel!.stream;
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
