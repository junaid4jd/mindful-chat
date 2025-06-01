import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/constants/app_lists.dart';
import 'package:mental_health_app/constants/content.dart';
import 'package:mental_health_app/config/app_config.dart';
import 'package:mental_health_app/providers/bottom_nav_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  final List<ChatMessage> initialMessages;

  const ChatScreen({
    Key? key,
    required this.initialMessages
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'You');
  final ChatUser _bot = ChatUser(id: '2', firstName: 'MindfulBot');

  late List<ChatMessage> _messages;
  late OpenAI _chatGPT;
  bool _isTyping = false;
  bool _useOfflineMode = false;

  // Mental health responses database for offline mode
  final Map<String, List<String>> _mentalHealthResponses = {
    'greeting': [
      "Hello! I'm here to support you. How are you feeling today?",
      "Hi there! I'm glad you're here. What's on your mind?",
      "Welcome! I'm here to listen and help. How can I support you today?",
      "Hello! It's good to see you. How are you doing right now?",
    ],
    'anxiety': [
      "I understand you're feeling anxious. That's completely valid. Try this: Take a slow breath in for 4 counts, hold for 4, then exhale for 6. This can help calm your nervous system.",
      "Anxiety can feel overwhelming, but you're not alone. One technique that helps many people is the 5-4-3-2-1 grounding method: Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.",
      "Thank you for sharing that you're feeling anxious. It takes courage to acknowledge these feelings. Would you like to try a quick breathing exercise together?",
      "Anxiety is your mind's way of trying to protect you, but sometimes it goes into overdrive. Remember: you are safe right now. Focus on your breath and the present moment.",
    ],
    'stress': [
      "Stress can feel overwhelming. Remember that it's okay to take breaks. Try progressive muscle relaxation: tense your shoulders for 5 seconds, then release and feel the tension melt away.",
      "I hear that you're feeling stressed. That's a normal response to challenging situations. One thing that can help is to write down three things you're grateful for today.",
      "Stress affects everyone differently. What usually helps you feel more relaxed? Sometimes even a short walk or listening to calming music can make a difference.",
      "When we're stressed, our breathing becomes shallow. Try placing one hand on your chest and one on your belly. Breathe so that the hand on your belly moves more than the one on your chest.",
    ],
    'sad': [
      "I'm sorry you're feeling sad. Your feelings are valid and it's okay to feel this way. Sometimes sadness is our heart's way of processing experiences.",
      "Sadness can feel heavy, but remember that emotions are temporary. They come and go like waves. You don't have to carry this feeling forever.",
      "Thank you for trusting me with your feelings. When you're ready, try to think of one small thing that brought you even a tiny bit of joy recently.",
      "It's okay to feel sad. Sometimes we need to honor these feelings rather than push them away. Are you able to be gentle with yourself today?",
    ],
    'motivation': [
      "Sometimes motivation feels hard to find, and that's completely normal. Start small - even tiny steps forward are still progress.",
      "You don't need to feel motivated to take action. Sometimes action creates motivation. What's one small thing you could do right now?",
      "Remember: you've overcome challenges before. You have strength within you, even when it doesn't feel like it. What's one thing you've accomplished recently that you're proud of?",
      "Motivation comes and goes, but your resilience remains. Focus on progress, not perfection. What's one small step you could take today?",
    ],
    'sleep': [
      "Sleep troubles can be frustrating. Try creating a calming bedtime routine: dim the lights an hour before bed, avoid screens, and try deep breathing or gentle stretching.",
      "Good sleep is so important for mental health. Consider keeping your bedroom cool, dark, and quiet. If your mind is racing, try writing down your thoughts before bed.",
      "Sleep difficulties often relate to stress or anxiety. Try the 4-7-8 breathing technique: inhale for 4, hold for 7, exhale for 8. This can help activate your body's relaxation response.",
      "Creating a consistent sleep schedule can help regulate your body's natural rhythm. Try to go to bed and wake up at the same time each day, even on weekends.",
    ],
    'breathing': [
      "Let's try a breathing exercise together. Breathe in slowly through your nose for 4 counts... hold for 4... now exhale through your mouth for 6 counts. Repeat this a few times.",
      "Focused breathing is one of the most effective ways to calm your nervous system. Try square breathing: in for 4, hold for 4, out for 4, hold for 4.",
      "When we're stressed, our breathing becomes shallow. Let's practice deep belly breathing: place one hand on your chest, one on your belly. Breathe so your belly hand moves more.",
      "Here's a simple technique: breathe in while counting to 3, then breathe out while counting to 6. The longer exhale helps activate your body's relaxation response.",
    ],
    'general': [
      "I'm here to listen. Would you like to tell me more about what you're experiencing?",
      "Thank you for sharing with me. How are you feeling right now in this moment?",
      "Your feelings are valid, and it's okay to feel however you're feeling. What kind of support would be most helpful?",
      "I appreciate you opening up. Sometimes just talking about our experiences can help. How has your day been?",
      "You're not alone in this. Many people experience similar feelings. What coping strategies have you tried before?",
    ],
    'encouragement': [
      "You're stronger than you know. Every day you keep going is a testament to your resilience.",
      "It's okay to have difficult days. What matters is that you're here, trying, and taking care of yourself.",
      "Remember: healing isn't linear. Some days will be better than others, and that's completely normal.",
      "You've survived 100% of your worst days so far. That's a pretty good track record.",
      "Taking the step to reach out for support shows incredible strength and self-awareness.",
    ],
  };

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.initialMessages);

    // Try to initialize OpenAI, but prepare for offline mode
    _initializeOpenAI();

    // Add welcome message if no initial messages
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _initializeOpenAI() {
    try {
      // Try to get API key from environment or config
      String apiKey = AppConfig.openaiApiKey;

      // If no environment key, use development key (you should set this)
      if (apiKey.isEmpty) {
        apiKey = AppConfig.developmentApiKey;
      }

      // If still no key, use offline mode
      if (apiKey.isEmpty || apiKey == 'sk-proj-YOUR_API_KEY_HERE') {
        print('No OpenAI API key found, using offline mode');
        _useOfflineMode = true;
        return;
      }

      _chatGPT = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 30),
          connectTimeout: const Duration(seconds: 30),
        ),
        enableLog: true,
      );
    } catch (e) {
      print('Failed to initialize OpenAI, using offline mode: $e');
      _useOfflineMode = true;
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      user: _bot,
      createdAt: DateTime.now(),
      text: _useOfflineMode
          ? "Hello! I'm MindfulBot. I'm currently in offline mode, but I'm still here to support you with mental health techniques and coping strategies. How are you feeling today?"
          : "Hello! I'm MindfulBot, your mental health support companion. I'm here to listen and offer support. How are you feeling today?",
    );
    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  Future<void> _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    // Try OpenAI first, fall back to offline mode if it fails
    if (!_useOfflineMode) {
      try {
        await _sendToOpenAI(message);
        return;
      } catch (e) {
        print('OpenAI failed, switching to offline mode: $e');
        _useOfflineMode = true;
        // Add a message about switching to offline mode
        final switchMessage = ChatMessage(
          user: _bot,
          createdAt: DateTime.now(),
          text: "I'm having trouble connecting to my advanced AI features, but I'm still here to help! I'll use my built-in mental health support responses.",
        );
        setState(() {
          _messages.insert(0, switchMessage);
        });
      }
    }

    // Use offline mode
    _sendOfflineResponse(message);
  }

  Future<void> _sendToOpenAI(ChatMessage message) async {
    List<Map<String, String>> conversationHistory = [];

    conversationHistory.add({
      'role': 'system',
      'content': '''You are MindfulBot, a compassionate mental health support AI. Provide empathetic, supportive responses with practical coping strategies. Keep responses under 150 words and encourage professional help when needed.''',
    });

    List<ChatMessage> recentMessages = _messages
        .take(6)
        .toList()
        .reversed
        .toList();
    for (ChatMessage msg in recentMessages) {
      String role = msg.user.id == _currentUser.id ? 'user' : 'assistant';
      conversationHistory.add({
        'role': role,
        'content': msg.text,
      });
    }

    final request = ChatCompleteText(
      messages: conversationHistory,
      maxToken: 150,
      model: GptTurbo0301ChatModel(),
      temperature: 0.7,
    );

    final response = await _chatGPT.onChatCompletion(request: request);

    if (response != null && response.choices.isNotEmpty) {
      final botResponse = response.choices.first.message?.content?.trim();

      if (botResponse != null && botResponse.isNotEmpty) {
        final botMessage = ChatMessage(
          user: _bot,
          createdAt: DateTime.now(),
          text: botResponse,
        );
        setState(() {
          _messages.insert(0, botMessage);
          _isTyping = false;
        });
        return;
      }
    }

    throw Exception('Empty or invalid response from OpenAI');
  }

  void _sendOfflineResponse(ChatMessage message) {
    // Add delay for more natural conversation flow
    Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(2000)), () {
      if (!mounted) return;

      final response = _generateOfflineResponse(message.text);
      final botMessage = ChatMessage(
        user: _bot,
        createdAt: DateTime.now(),
        text: response,
      );

      setState(() {
        _messages.insert(0, botMessage);
        _isTyping = false;
      });
    });
  }

  String _generateOfflineResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    final random = Random();

    // Check for specific keywords and respond accordingly
    if (message.contains('hello') || message.contains('hi') ||
        message.contains('hey')) {
      return _mentalHealthResponses['greeting']![random.nextInt(
          _mentalHealthResponses['greeting']!.length)];
    }

    if (message.contains('anxious') || message.contains('anxiety') ||
        message.contains('worried') || message.contains('panic')) {
      return _mentalHealthResponses['anxiety']![random.nextInt(
          _mentalHealthResponses['anxiety']!.length)];
    }

    if (message.contains('stress') || message.contains('overwhelmed') ||
        message.contains('pressure')) {
      return _mentalHealthResponses['stress']![random.nextInt(
          _mentalHealthResponses['stress']!.length)];
    }

    if (message.contains('sad') || message.contains('depressed') ||
        message.contains('down') || message.contains('upset')) {
      return _mentalHealthResponses['sad']![random.nextInt(
          _mentalHealthResponses['sad']!.length)];
    }

    if (message.contains('motivation') || message.contains('unmotivated') ||
        message.contains('lazy') || message.contains('energy')) {
      return _mentalHealthResponses['motivation']![random.nextInt(
          _mentalHealthResponses['motivation']!.length)];
    }

    if (message.contains('sleep') || message.contains('insomnia') ||
        message.contains('tired') || message.contains('rest')) {
      return _mentalHealthResponses['sleep']![random.nextInt(
          _mentalHealthResponses['sleep']!.length)];
    }

    if (message.contains('breathing') || message.contains('breathe') ||
        message.contains('breath')) {
      return _mentalHealthResponses['breathing']![random.nextInt(
          _mentalHealthResponses['breathing']!.length)];
    }

    if (message.contains('help') || message.contains('support') ||
        message.contains('advice')) {
      return _mentalHealthResponses['encouragement']![random.nextInt(
          _mentalHealthResponses['encouragement']!.length)];
    }

    // Default to general supportive responses
    return _mentalHealthResponses['general']![random.nextInt(
        _mentalHealthResponses['general']!.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Back button
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                final bottomNav = Provider.of<BottomNavProvider>(
                    context, listen: false);
                Navigator.pop(context, _messages);
                bottomNav.setIndex(0, context);
              },
            ),

            // Profile image
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purpleColor, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),

            SizedBox(width: 12),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MindfulBot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _isTyping ? 'Typing...' : _useOfflineMode
                        ? 'Offline Mode'
                        : 'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isTyping ? Colors.orange : _useOfflineMode
                          ? Colors.blue
                          : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              switch (value) {
                case 'clear':
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: const Text('Clear chat?'),
                          content: const Text('This will delete all messages.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    setState(() {
                      _messages.clear();
                      _addWelcomeMessage();
                    });
                  }
                  break;
                case 'mode':
                  setState(() {
                    _useOfflineMode = !_useOfflineMode;
                  });
                  final modeMessage = ChatMessage(
                    user: _bot,
                    createdAt: DateTime.now(),
                    text: _useOfflineMode
                        ? "Switched to offline mode. I'll use my built-in mental health responses."
                        : "Switched to online mode. I'll try to use advanced AI features.",
                  );
                  setState(() {
                    _messages.insert(0, modeMessage);
                  });
                  break;
                case 'crisis':
                  _showCrisisResources();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: 'mode',
                child: Row(
                  children: [
                    Icon(_useOfflineMode ? Icons.wifi : Icons.wifi_off,
                        color: Colors.blue),
                    SizedBox(width: 8),
                    Text(_useOfflineMode
                        ? 'Try Online Mode'
                        : 'Use Offline Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'crisis',
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Crisis Resources'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('About MindfulBot'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Connection status banner
          if (_useOfflineMode)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.offline_bolt, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode: Using built-in mental health responses',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Quick suggestion chips
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildSuggestionChip("Hello"),
                _buildSuggestionChip("I'm feeling anxious"),
                _buildSuggestionChip("I need motivation"),
                _buildSuggestionChip("Breathing exercise"),
                _buildSuggestionChip("I'm stressed"),
                _buildSuggestionChip("Sleep problems"),
              ],
            ),
          ),

          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: _messages,
              onSend: _sendMessage,

              messageOptions: MessageOptions(
                showTime: true,
                timeFormat: DateFormat('h:mm a'),
                currentUserContainerColor: AppColors.purpleColor,
                containerColor: Colors.white,
                textColor: Colors.black,
                currentUserTextColor: Colors.white,
                messagePadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                borderRadius: 20,
                avatarBuilder: (user, onPress, onLongPress) {
                  if (user.id == _bot.id) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.purpleColor, Colors.blue.shade300],
                        ),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  } else {
                    return CircleAvatar(
                      backgroundColor: AppColors.purpleColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppColors.purpleColor,
                        size: 18,
                      ),
                    );
                  }
                },
              ),

              inputOptions: InputOptions(
                alwaysShowSend: true,
                inputToolbarPadding: const EdgeInsets.all(16),
                inputDecoration: InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: AppColors.purpleColor, width: 2),
                  ),
                ),
                sendButtonBuilder: (onSend) =>
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.purpleColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purpleColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                    onPressed: onSend,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.purpleColor.withOpacity(0.3)),
        onPressed: () {
          final message = ChatMessage(
            user: _currentUser,
            createdAt: DateTime.now(),
            text: text,
          );
          _sendMessage(message);
        },
      ),
    );
  }

  void _showCrisisResources() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.emergency, color: Colors.red),
                SizedBox(width: 8),
                Text('Crisis Resources'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'If you\'re in immediate danger or having thoughts of self-harm, please reach out for help:',
                    style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              _buildCrisisItem('Emergency Services', '911'),
              _buildCrisisItem('National Suicide Prevention Lifeline', '988'),
              _buildCrisisItem('Crisis Text Line', 'Text HOME to 741741'),
              _buildCrisisItem('SAMHSA National Helpline', '1-800-662-4357'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisItem(String title, String contact) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            contact,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('About MindfulBot'),
            content: Text(
              'MindfulBot is a mental health support companion that provides empathetic responses and coping strategies.\n\n'
                  '${_useOfflineMode
                  ? "• Currently in offline mode with built-in responses"
                  : "• Online mode with AI assistance"}\n'
                  '• Available 24/7 for support\n'
                  '• Offers evidence-based techniques\n'
                  '• Crisis resources available\n'
                  '• Respects your privacy\n\n'
                  'Remember: MindfulBot is not a replacement for professional therapy. For serious concerns, please consult with a qualified mental health professional.',
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class SimpleChat extends StatelessWidget {
  const SimpleChat({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatScreen(initialMessages: []);
  }
}
