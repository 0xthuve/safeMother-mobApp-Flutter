import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'navigation_handler.dart';

void main() {
  // Ensure .env is loaded before running the app
  dotenv.load().then((_) {
    runApp(const PregnancyApp());
  });
}

class PregnancyApp extends StatelessWidget {
  const PregnancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - AI Chat',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentIndex = 4; // Chat is active
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // Groq API credentials
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  
  // Sample chat messages
  final List<Map<String, dynamic>> _messages = [
    {
      'text': "Hello! I'm your pregnancy assistant. How can I help you today?",
      'isMe': false,
      'sender': 'Pregnancy Assistant',
      'time': 'Now',
      'hasAttachment': false,
    },
  ];

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  // Function to send message to Groq API
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    
    final String userMessage = _messageController.text;
    _messageController.clear();
    
    // Add user message to chat
    setState(() {
      _messages.add({
        'text': userMessage,
        'isMe': true,
        'sender': 'You',
        'time': 'Now',
        'hasAttachment': false,
      });
      _isLoading = true;
    });
    
    // Scroll to bottom
    _scrollToBottom();
    
    try {
      // Prepare the API request for Groq
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'llama-3.1-8b-instant', // Using a valid Groq model
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful pregnancy assistant. Only answer questions related to pregnancy, prenatal care, childbirth, postpartum care, and newborn care. If asked about other topics, politely decline and redirect back to pregnancy-related topics. Your name is "Pregnancy Assistant".',
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String assistantMessage = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add({
            'text': assistantMessage,
            'isMe': false,
            'sender': 'Pregnancy Assistant',
            'time': 'Now',
            'hasAttachment': false,
          });
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get response from API: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'text': "Sorry, I'm having trouble connecting right now. Please try again later. Error: ${e.toString()}",
          'isMe': false,
          'sender': 'Pregnancy Assistant',
          'time': 'Now',
          'hasAttachment': false,
        });
        _isLoading = false;
      });
    }
    
    // Scroll to bottom again after response
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.assignment_outlined, 'Log', 1),
            _buildNavItem(Icons.notifications_outlined, 'Reminders', 2),
            _buildNavItem(Icons.school_outlined, 'Learn', 3),
            _buildNavItem(Icons.chat_outlined, 'Chat', 4),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(0xFFD1C4E9).withOpacity(0.4),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3),
              ),
            ),
          ),
          
          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFC5CAE9).withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          NavigationHandler.navigateToScreen(context, 0); // Go to Home
                        },
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE91E63),
                        child: Icon(Icons.pregnant_woman, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pregnancy Assistant',
                            style: TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'AI-powered support',
                            style: TextStyle(
                              color: Color(0xFF638763),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Clear chat
                          setState(() {
                            _messages.clear();
                            _messages.add({
                              'text': "Hello! I'm your pregnancy assistant. How can I help you today?",
                              'isMe': false,
                              'sender': 'Pregnancy Assistant',
                              'time': 'Now',
                              'hasAttachment': false,
                            });
                          });
                        },
                        icon: const Icon(Icons.delete, color: Color(0xFF7B1FA2)),
                      ),
                    ],
                  ),
                ),
                
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        final message = _messages[index];
                        return _buildMessageBubble(
                          text: message['text'],
                          isMe: message['isMe'],
                          sender: message['sender'],
                          time: message['time'],
                          hasAttachment: message['hasAttachment'],
                        );
                      } else {
                        // Loading indicator when waiting for response
                        return _buildLoadingIndicator();
                      }
                    },
                  ),
                ),
                
                // Message input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4EF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ask a pregnancy-related question...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Color(0xFF638763)),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Suggest common pregnancy questions
                                  _showQuestionSuggestions();
                                },
                                icon: const Icon(Icons.lightbulb_outline, color: Color(0xFF638763)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: _isLoading 
                            ? Colors.grey 
                            : const Color(0xFFE91E63),
                        child: IconButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showQuestionSuggestions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Common Pregnancy Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B1FA2),
                ),
              ),
              const SizedBox(height: 16),
              _buildSuggestionItem('What foods should I avoid during pregnancy?'),
              _buildSuggestionItem('What are safe exercises for the third trimester?'),
              _buildSuggestionItem('How can I relieve morning sickness?'),
              _buildSuggestionItem('What are the signs of preterm labor?'),
              _buildSuggestionItem('How much weight should I gain during pregnancy?'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSuggestionItem(String question) {
    return ListTile(
      title: Text(question),
      onTap: () {
        Navigator.pop(context);
        _messageController.text = question;
        _sendMessage();
      },
    );
  }
  
  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String sender,
    required String time,
    required bool hasAttachment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) 
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE91E63),
              child: Icon(Icons.pregnant_woman, color: Colors.white, size: 18),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      sender,
                      style: const TextStyle(
                        color: Color(0xFF638763),
                        fontSize: 12,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF14B714) : const Color(0xFFEFF4EF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF111611),
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF638763),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE91E63),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE91E63),
            child: Icon(Icons.pregnant_woman, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    'Pregnancy Assistant',
                    style: TextStyle(
                      color: Color(0xFF638763),
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4EF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: const Radius.circular(4),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF638763)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Thinking...',
                        style: TextStyle(
                          color: Color(0xFF111611),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}