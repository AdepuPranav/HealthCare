import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Changed to dynamic to store original text
  final ScrollController _scrollController = ScrollController();
  bool _isBotTyping = false;

  // Create translator instance
  final GoogleTranslator translator = GoogleTranslator();

  // Language selection
  String _selectedLanguage = 'english';
  final List<String> _languages = ['english', 'hindi', 'tamil', 'telugu'];
  final Map<String, String> _languageCodes = {
    'english': 'en',
    'hindi': 'hi',
    'tamil': 'ta',
    'telugu': 'te',
  };
  double _languageSliderValue = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<String> translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return text;

    try {
      final String languageCode = _languageCodes[targetLanguage.toLowerCase()] ?? 'en';
      final translation = await translator.translate(text, to: languageCode);
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text if translation fails
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "user",
        "text": message,
        "original_text": message, // Store original message
      });
    });

    _controller.clear();
    _scrollToBottom();

    setState(() {
      _isBotTyping = true;
    });
    _scrollToBottom();

    final url = Uri.parse('http://192.168.96.253:8000/get-response');

    try {
      // Always request English response from the backend
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'display_language': 'english' // Always request English
        }),
      );

      setState(() {
        _isBotTyping = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String englishResponse = data['response'];

        // Translate if not English
        if (_selectedLanguage.toLowerCase() != 'english') {
          String translatedResponse = await translateText(englishResponse, _selectedLanguage);
          setState(() {
            _messages.add({
              "sender": "bot",
              "text": translatedResponse,
              "original_text": englishResponse, // Store the original English text
            });
          });
        } else {
          setState(() {
            _messages.add({
              "sender": "bot",
              "text": englishResponse,
              "original_text": englishResponse, // Same for English
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "Error: Bot unreachable.",
            "original_text": "Error: Bot unreachable.",
          });
        });
      }
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        _messages.add({
          "sender": "bot",
          "text": "Error: $e",
          "original_text": "Error: $e",
        });
      });
    }

    _scrollToBottom();
  }

  Widget buildMessage(Map<String, dynamic> message) {
    final isUser = message["sender"] == "user";

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) _buildBotAvatar(),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isUser ? Colors.tealAccent[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message["text"] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        if (isUser) _buildUserAvatar(),
      ],
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.teal,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.health_and_safety,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.tealAccent[700],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Response Language:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _selectedLanguage[0].toUpperCase() + _selectedLanguage.substring(1),
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _languages.map((lang) {
              return Text(
                lang[0].toUpperCase() + lang.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedLanguage == lang ? Colors.teal : Colors.grey,
                  fontWeight: _selectedLanguage == lang ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.teal,
            inactiveTrackColor: Colors.teal.withOpacity(0.3),
            thumbColor: Colors.tealAccent[700],
            overlayColor: Colors.teal.withOpacity(0.4),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: _languageSliderValue,
            min: 0,
            max: _languages.length - 1,
            divisions: _languages.length - 1,
            onChanged: (value) {
              setState(() {
                _languageSliderValue = value;
                _selectedLanguage = _languages[value.round()];
                // Translate all existing messages when language changes
                _updateMessagesForLanguage();
              });
            },
          ),
        ),
      ],
    );
  }

  // This method updates all messages for the selected language
  Future<void> _updateMessagesForLanguage() async {
    setState(() {
      _isBotTyping = true; // Show loading while translating
    });

    List<Map<String, dynamic>> updatedMessages = [];

    for (var message in _messages) {
      String originalText = message["original_text"] ?? '';

      if (_selectedLanguage.toLowerCase() == 'english') {
        // For English, use the original text
        if (message["sender"] == "bot") {
          updatedMessages.add({
            "sender": message["sender"],
            "text": originalText,
            "original_text": originalText
          });
        } else {
          // Keep user messages as they are
          updatedMessages.add(message);
        }
      } else {
        // For other languages, translate bot messages
        if (message["sender"] == "bot") {
          String translatedText = await translateText(originalText, _selectedLanguage);
          updatedMessages.add({
            "sender": message["sender"],
            "text": translatedText,
            "original_text": originalText
          });
        } else {
          // Keep user messages as they are
          updatedMessages.add(message);
        }
      }
    }

    setState(() {
      _messages.clear();
      _messages.addAll(updatedMessages);
      _isBotTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthBot Chat"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return buildMessage(_messages[index]);
                }
                return const TypingIndicator();
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (text) => sendMessage(text),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () => sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildAvatar(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                children: [
                  _buildDot(0),
                  const SizedBox(width: 4),
                  _buildDot(1),
                  const SizedBox(width: 4),
                  _buildDot(2),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    double begin = index * 0.2;
    double end = begin + 0.6;

    return Transform.translate(
      offset: Offset(0,
          Tween<double>(begin: -3.0, end: 0.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, end, curve: Curves.easeOut),
          )).value),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.teal,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.health_and_safety,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}