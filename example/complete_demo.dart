import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Flutter AI Agent SDK - Complete Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AgentDemoHome(),
      );
}

class AgentDemoHome extends StatefulWidget {
  const AgentDemoHome({super.key});

  @override
  State<AgentDemoHome> createState() => _AgentDemoHomeState();
}

class _AgentDemoHomeState extends State<AgentDemoHome> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    BasicChatPage(),
    VoiceChatPage(),
    ToolsDemoPage(),
    SettingsPage(),
  ];

  void _onItemTapped(final int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter AI Agent SDK Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Basic Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Voice Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: 'Tools Demo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      );
}

class BasicChatPage extends StatefulWidget {
  const BasicChatPage({super.key});

  @override
  BasicChatPageState createState() => BasicChatPageState();
}

class BasicChatPageState extends State<BasicChatPage> {
  late VoiceAgent _agent;
  AgentSession? _session;
  final List<Message> _messages = <Message>[];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  @override
  Future<void> initState() async {
    super.initState();
    await _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    setState(() => _isLoading = true);

    try {
      // Create LLM Provider
      final OpenAIProvider llmProvider = OpenAIProvider(
        apiKey: 'your-openai-api-key-here', // Replace with your key
      );

      // Create Agent Configuration
      final AgentConfig config = AgentConfig(
        name: 'Demo Assistant',
        instructions: '''
          You are a helpful AI assistant in a demo application.
          Be friendly, informative, and engaging.
          You can help with general questions, coding, and more.
        ''',
        llmProvider: llmProvider,
        sttService: NativeSTTService(),
        ttsService: NativeTTSService(),
      );

      _agent = VoiceAgent(config: config);
      _session = await _agent.createSession();

      // Listen to session events
      _session!.events.listen((final AgentEvent event) {
        if (event is MessageReceivedEvent) {
          setState(() {
            _messages.add(event.message);
          });
        }
      });
    } catch (e) {
      print('Error initializing agent: $e');
      // Show error in UI
      setState(() {
        _messages.add(
          Message(
            id: 'error',
            role: MessageRole.system,
            content: 'Error initializing agent: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty || _session == null) {
      return;
    }

    // Add user message
    setState(() {
      _messages.add(
        Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.user,
          content: text,
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      );
    });

    _textController.clear();

    try {
      // Send message to agent
      await _session!.sendMessage(text);
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            id: 'error_${DateTime.now().millisecondsSinceEpoch}',
            role: MessageRole.system,
            content: 'Error: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            // Status indicator
            Container(
              padding: const EdgeInsets.all(8),
              color: _isLoading ? Colors.orange : Colors.green,
              child: Row(
                children: <Widget>[
                  Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLoading ? 'Initializing...' : 'Ready',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Start a conversation!\n\nThis demo shows basic text chat with the AI agent.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey<String>('messages_list'),
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder:
                          (final BuildContext context, final int index) {
                        final Message message = _messages[index];
                        final bool isUser = message.role == MessageRole.user;
                        final bool isSystem =
                            message.role == MessageRole.system;

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : isSystem
                                      ? Colors.red[100]
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.content ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (final _) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Future<void> dispose() async {
    _textController.dispose();
    await _session?.dispose();
    _agent.dispose();
    super.dispose();
  }
}

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  VoiceChatPageState createState() => VoiceChatPageState();
}

class VoiceChatPageState extends State<VoiceChatPage> {
  late VoiceAgent _agent;
  AgentSession? _session;
  final List<Message> _messages = <Message>[];
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isLoading = true;
  @override
  Future<void> initState() async {
    super.initState();
    await _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    setState(() => _isLoading = true);

    try {
      final OpenAIProvider llmProvider = OpenAIProvider(
        apiKey: 'your-openai-api-key-here', // Replace with your key
      );

      final AgentConfig config = AgentConfig(
        name: 'Voice Assistant',
        instructions: '''
          You are a voice-enabled AI assistant.
          Speak naturally and conversationally.
          Keep responses concise but informative.
        ''',
        llmProvider: llmProvider,
        sttService: NativeSTTService(),
        ttsService: NativeTTSService(),
      );

      _agent = VoiceAgent(config: config);
      _session = await _agent.createSession();

      // Listen to session state changes
      _session!.state.listen((final SessionStatus state) {
        setState(() {
          _isListening = state.isListening;
          _isSpeaking = state.isSpeaking;
        });
      });

      // Listen to events
      _session!.events.listen((final AgentEvent event) {
        if (event is MessageReceivedEvent) {
          setState(() {
            _messages.add(event.message);
          });
        }
      });
    } catch (e) {
      print('Error initializing voice agent: $e');
      setState(() {
        _messages.add(
          Message(
            id: 'error',
            role: MessageRole.system,
            content: 'Error: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleListening() async {
    if (_session == null) {
      return;
    }

    try {
      if (_isListening) {
        await _session!.stopListening();
      } else {
        await _session!.startListening();
      }
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            id: 'error_${DateTime.now().millisecondsSinceEpoch}',
            role: MessageRole.system,
            content: 'Voice error: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            // Voice status
            Container(
              padding: const EdgeInsets.all(16),
              color: _isListening ? Colors.blue : Colors.grey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _isListening ? 'Listening...' : 'Tap to speak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_isSpeaking)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Speaking...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.mic, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Voice Chat Demo\n\nTap the microphone to start speaking!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey<String>('messages_list'),
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder:
                          (final BuildContext context, final int index) {
                        final Message message = _messages[index];
                        final bool isUser = message.role == MessageRole.user;

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.content ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Voice control
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label:
                    Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Future<void> dispose() async {
    await _session?.dispose();
    _agent.dispose();
    super.dispose();
  }
}

class ToolsDemoPage extends StatefulWidget {
  const ToolsDemoPage({super.key});

  @override
  ToolsDemoPageState createState() => ToolsDemoPageState();
}

class ToolsDemoPageState extends State<ToolsDemoPage> {
  late VoiceAgent _agent;
  AgentSession? _session;
  final List<Message> _messages = <Message>[];
  final List<String> _availableTools = <String>[
    'Weather',
    'Calculator',
    'Time',
  ];
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeAgent());
  }

  Future<void> _initializeAgent() async {
    setState(() => _isLoading = true);

    try {
      final OpenAIProvider llmProvider = OpenAIProvider(
        apiKey: 'your-openai-api-key-here', // Replace with your key
      );

      // Create custom tools
      final List<FunctionTool> tools = <FunctionTool>[
        FunctionTool(
          name: 'get_weather',
          description: 'Get current weather for a location',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, Map<String, Object>>{
              'location': <String, String>{
                'type': 'string',
                'description': 'City name',
              },
              'unit': <String, Object>{
                'type': 'string',
                'enum': <String>['celsius', 'fahrenheit'],
              },
            },
            'required': <String>['location'],
          },
          function: (final Map<String, dynamic> args) async {
            final String location = args['location'] as String;
            final String unit = args['unit'] as String? ?? 'celsius';

            // Simulate API call
            await Future<void>.delayed(const Duration(seconds: 1));

            return <String, Object>{
              'temperature': unit == 'celsius' ? 22 : 72,
              'condition': 'sunny',
              'location': location,
              'unit': unit,
            };
          },
        ),
        FunctionTool(
          name: 'calculate',
          description: 'Perform mathematical calculations',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, Map<String, String>>{
              'expression': <String, String>{
                'type': 'string',
                'description': 'Math expression',
              },
            },
            'required': <String>['expression'],
          },
          function: (final Map<String, dynamic> args) async {
            final String expression = args['expression'] as String;

            // Simple calculation simulation
            await Future<void>.delayed(const Duration(milliseconds: 500));

            try {
              // This is a simple simulation -
              // in real app you'd use a proper calculator
              if (expression.contains('+')) {
                final List<String> parts = expression.split('+');
                final int result =
                    int.parse(parts[0].trim()) + int.parse(parts[1].trim());
                return <String, Object>{
                  'result': result,
                  'expression': expression,
                };
              } else if (expression.contains('*')) {
                final List<String> parts = expression.split('*');
                final int result =
                    int.parse(parts[0].trim()) * int.parse(parts[1].trim());
                return <String, Object>{
                  'result': result,
                  'expression': expression,
                };
              } else {
                return <String, Object>{
                  'result': 0,
                  'expression': expression,
                  'error': 'Unsupported operation',
                };
              }
            } catch (e) {
              return <String, Object>{
                'result': 0,
                'expression': expression,
                'error': 'Invalid expression',
              };
            }
          },
        ),
        FunctionTool(
          name: 'get_current_time',
          description: 'Get current time for a timezone',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, Map<String, String>>{
              'timezone': <String, String>{
                'type': 'string',
                'description': 'Timezone (e.g., America/New_York)',
              },
            },
            'required': <String>['timezone'],
          },
          function: (final Map<String, dynamic> args) async {
            final String timezone = args['timezone'] as String;

            // Simulate API call
            await Future<void>.delayed(const Duration(milliseconds: 800));

            return <String, String>{
              'time': DateTime.now().toString(),
              'timezone': timezone,
            };
          },
        ),
      ];

      final AgentConfig config = AgentConfig(
        name: 'Tools Assistant',
        instructions: '''
          You are an AI assistant with access to various tools.
          Use the available tools to help users with weather, calculations, and time queries.
          Always explain what you're doing when using tools.
        ''',
        llmProvider: llmProvider,
        sttService: NativeSTTService(),
        ttsService: NativeTTSService(),
        tools: tools,
      );

      _agent = VoiceAgent(config: config);
      _session = await _agent.createSession();

      // Listen to events including tool executions
      _session!.events.listen((final AgentEvent event) {
        if (event is MessageReceivedEvent) {
          setState(() {
            _messages.add(event.message);
          });
        } else if (event is ToolCallCompletedEvent) {
          setState(() {
            _messages.add(
              Message(
                id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
                role: MessageRole.system,
                content:
                    '🔧 Used tool: ${event.toolName}\nResult: ${event.result}',
                timestamp: DateTime.now(),
                type: MessageType.text,
              ),
            );
          });
        }
      });
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            id: 'error',
            role: MessageRole.system,
            content: 'Error: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final String text = _inputController.text.trim();
    if (text.isEmpty || _session == null) {
      return;
    }

    setState(() {
      _messages.add(
        Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.user,
          content: text,
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      );
    });

    _inputController.clear();

    try {
      await _session!.sendMessage(text);
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            id: 'error_${DateTime.now().millisecondsSinceEpoch}',
            role: MessageRole.system,
            content: 'Error: $e',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ),
        );
      });
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            // Tools info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '🛠️ Tools Demo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available tools: ${_availableTools.join(", ")}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try asking:'
                    ' "What\'s the weather in New York?" or "What\'s 15 + 27?"',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.build, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Tools Demo\n\nAsk me to use'
                            ' tools like weather or calculator!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey<String>('messages_list'),
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder:
                          (final BuildContext context, final int index) {
                        final Message message = _messages[index];
                        final bool isUser = message.role == MessageRole.user;
                        final bool isSystem =
                            message.role == MessageRole.system;

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue
                                  : isSystem
                                      ? Colors.orange[100]
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isUser ? Colors.white : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Ask me to use a tool...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (final _) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Future<void> dispose() async {
    _inputController.dispose();
    await _session?.dispose();
    _agent.dispose();
    super.dispose();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '⚙️ Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // API Configuration
              _SettingsCard(
                title: 'API Configuration',
                icon: Icons.key,
                children: <Widget>[
                  ListTile(
                    title: const Text('OpenAI API Key'),
                    subtitle: const Text('Configure your OpenAI API key'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to API key configuration
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Agent Settings
              _SettingsCard(
                title: 'Agent Settings',
                icon: Icons.smart_toy,
                children: <Widget>[
                  ListTile(
                    title: const Text('Voice Settings'),
                    subtitle: const Text(
                      'Configure speech recognition and synthesis',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Memory Settings'),
                    subtitle: const Text('Manage conversation memory'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About
              _SettingsCard(
                title: 'About',
                icon: Icons.info,
                children: <Widget>[
                  const ListTile(
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Documentation'),
                    subtitle: const Text('View complete documentation'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Support'),
                    subtitle: const Text('Get help and contact support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ],
              ),

              const Spacer(),

              // Demo info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Flutter AI Agent SDK Demo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This demo showcases the capabilities of the Flutter AI Agent SDK including basic chat, voice interaction, and tool usage.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      );
}
