
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class GFStatusScreen extends StatefulWidget {
  final String boyfriendUserId;

  const GFStatusScreen({super.key, required this.boyfriendUserId});

  @override
  State<GFStatusScreen> createState() => _GFStatusScreenState();
}

class _GFStatusScreenState extends State<GFStatusScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> _activity = {};
  bool _isLoading = true;
  Timer? _refreshTimer;
  bool _isDisconnected = false;
  bool _isMounted = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, Map<String, Color>> _gameThemes = {
    "Valorant": {
      "primary": Color(0xFFFD4556),
      "secondary": Color(0xFF0F1923),
      "accent": Color(0xFFFF4655),
    },
    "Counter-Strike": {
      "primary": Color(0xFF2C3E50),
      "secondary": Color(0xFFE67E22),
      "accent": Color(0xFFF39C12),
    },
    "GTA": {
      "primary": Color(0xFF1B5E20),
      "secondary": Color(0xFF4CAF50),
      "accent": Color(0xFF66BB6A),
    },
    "Minecraft": {
      "primary": Color(0xFF4CAF50),
      "secondary": Color(0xFF2E7D32),
      "accent": Color(0xFF81C784),
    },
    "Fortnite": {
      "primary": Color(0xFF2B2B7A),
      "secondary": Color(0xFF9147FF),
      "accent": Color(0xFFB845FF),
    },
    "Apex": {
      "primary": Color(0xFFD32F2F),
      "secondary": Color(0xFFF5A623),
      "accent": Color(0xFFF5A623),
    },
    "League": {
      "primary": Color(0xFF0A323C),
      "secondary": Color(0xFFC8A86A),
      "accent": Color(0xFFD4AF37),
    },
    "Dota": {
      "primary": Color(0xFF2B2B2B),
      "secondary": Color(0xFFDC143C),
      "accent": Color(0xFFFF4444),
    },
    "Call of Duty": {
      "primary": Color(0xFF1A1A1A),
      "secondary": Color(0xFFB8860B),
      "accent": Color(0xFFDAA520),
    },
    "PUBG": {
      "primary": Color(0xFFE65100),
      "secondary": Color(0xFF1B1B1B),
      "accent": Color(0xFFFF6D00),
    },
    "Overwatch": {
      "primary": Color(0xFFF99E1A),
      "secondary": Color(0xFFD4AF37),
      "accent": Color(0xFFFFB347),
    },
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(_pulseController);
    _fetchStatus();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isMounted) _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    if (!_isMounted) return;
    try {
      final response = await http.get(
        Uri.parse(
          'http://"backend url"/api/get-activity/${widget.boyfriendUserId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
          "📱 Status: ${data['status']}, Game: ${data['game']}, Streaming: ${data['is_streaming']}",
        );
        if (_isMounted) {
          setState(() {
            _activity = data;
            _isLoading = false;
            _isDisconnected = false;
          });
        }
      } else if (response.statusCode == 404 && _isMounted) {
        setState(() {
          _isDisconnected = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (_isMounted) {
        setState(() {
          _isDisconnected = true;
          _isLoading = false;
        });
      }
    }
  }

  Map<String, Color> _getGameTheme(String gameName) {
    for (var entry in _gameThemes.entries) {
      if (gameName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return {
      "primary": Color(0xFF7C3AED),
      "secondary": Color(0xFFEC4899),
      "accent": Color(0xFF8B5CF6),
    };
  }

  Gradient _getStatusGradient() {
    String status = _activity['status'] ?? 'available';
    String game = _activity['game'] ?? '';
    bool isStreaming = _activity['is_streaming'] ?? false;

    if (status == 'streaming_only') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6441A5), Color(0xFFE1306C)],
      );
    } else if (status == 'actively_playing' && isStreaming) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFD4556), Color(0xFF9147FF)],
        stops: [0.3, 0.7],
      );
    } else if (status == 'actively_playing') {
      Map<String, Color> gameTheme = _getGameTheme(game);
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gameTheme["primary"]!, gameTheme["secondary"]!],
      );
    } else if (status == 'game_running') {
      Map<String, Color> gameTheme = _getGameTheme(game);
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gameTheme["primary"]!.withValues(alpha: 0.7),
          gameTheme["secondary"]!.withValues(alpha: 0.5),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      );
    }
  }

  String _getGameIcon(String gameName) {
    if (gameName.toLowerCase().contains("valorant")) return "🎯";
    if (gameName.toLowerCase().contains("counter")) return "🔫";
    if (gameName.toLowerCase().contains("gta")) return "🏎️";
    if (gameName.toLowerCase().contains("minecraft")) return "⛏️";
    if (gameName.toLowerCase().contains("fortnite")) return "🎈";
    if (gameName.toLowerCase().contains("apex")) return "🔺";
    if (gameName.toLowerCase().contains("league")) return "🏆";
    if (gameName.toLowerCase().contains("dota")) return "🗡️";
    return "🎮";
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _sendUrgentMessage() async {
    final TextEditingController messageController = TextEditingController();
    if (!_isMounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Send Urgent Message',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your boyfriend is currently gaming',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  maxLength: 250,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (messageController.text.trim().isEmpty) {
                            _showSnackBar(
                              'Please enter a message',
                              isError: true,
                            );
                            return;
                          }
                          Navigator.pop(dialogContext);
                          setState(() => _isLoading = true);
                          try {
                            final response = await http.post(
                              Uri.parse(
                                'http://"backend url"/api/send-urgent-message',
                              ),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                'to_user_id': widget.boyfriendUserId,
                                'from_user_id': 'GF',
                                'message': messageController.text.trim(),
                                'timestamp': DateTime.now().toIso8601String(),
                              }),
                            );
                            if (response.statusCode == 200) {
                              _showSnackBar('✅ Message sent successfully!');
                            } else {
                              _showSnackBar(
                                'Failed to send message',
                                isError: true,
                              );
                            }
                          } catch (e) {
                            _showSnackBar('Failed to send: $e', isError: true);
                          } finally {
                            if (_isMounted) setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('is_logged_in');
      await prefs.remove('login_role');
      await prefs.remove('pc_code');
      await prefs.remove('connected_to');

      debugPrint("✅ Session cleared on logout");

      if (_isMounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      _showSnackBar('Logout failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Partner'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: _sendUrgentMessage,
            tooltip: 'Send Message',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isDisconnected
          ? _buildDisconnectedView()
          : _buildMainView(),
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Partner is offline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask them to start the app',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go Back'),
          ),
          const SizedBox(height: 40),
          Text(
            "Made For Her ❤️",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    String status = _activity['status'] ?? 'available';
    String game = _activity['game'] ?? '';
    bool isStreaming = _activity['is_streaming'] ?? false;
    String gameIcon = _getGameIcon(game);

    String displayText = "";
    String badgeText = "";

    if (status == 'streaming_only') {
      displayText = "Streaming";
      badgeText = "🔴 LIVE";
    } else if (isStreaming && status == 'actively_playing') {
      displayText = "Playing $game";
      badgeText = "LIVE + GAMING";
    } else if (isStreaming) {
      displayText = "Streaming";
      badgeText = "🔴 LIVE";
    } else if (status == 'actively_playing' && game.isNotEmpty) {
      displayText = "Playing $game";
      badgeText = "ACTIVE NOW";
    } else if (status == 'game_running' && game.isNotEmpty) {
      displayText = "$game is running";
      badgeText = "IN GAME";
    } else if (status == 'actively_playing') {
      displayText = "Playing Game";
      badgeText = "ACTIVE NOW";
    } else {
      displayText = "Available";
      badgeText = "AVAILABLE";
    }

    return RefreshIndicator(
      onRefresh: _fetchStatus,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale:
                                    (status == 'actively_playing' ||
                                        isStreaming)
                                    ? _pulseAnimation.value
                                    : 1.0,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                isStreaming
                                    ? "🎮"
                                    : (status == 'actively_playing'
                                          ? gameIcon
                                          : "💚"),
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                          if (isStreaming)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isStreaming) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isStreaming && _activity['stream_software'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "🎥 Streaming on ${_activity['stream_software']}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildMessageCard(),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    "Made For Her ❤️",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sendUrgentMessage,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.send, color: Colors.red.shade400, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to send urgent message',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.update, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Last updated',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Text(
                _activity['last_updated'] != null
                    ? _formatTime(_activity['last_updated'])
                    : 'Just now',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.link, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Connected to',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Text(
                widget.boyfriendUserId,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
}
