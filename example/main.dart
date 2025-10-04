import 'package:flutter/material.dart';
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'AI Agent Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AgentDemoPage(),
      );
}

class AgentDemoPage extends StatefulWidget {
  const AgentDemoPage({super.key});

  @override
  State<AgentDemoPage> createState() => _AgentDemoPageState();
}

class _AgentDemoPageState extends State<AgentDemoPage> {
  late VoiceAgent _agent;
  AgentSession? _session;
  final List<Message> _messages = <Message>[];
  SessionStatus _status = const SessionStatus(state: SessionState.idle);

  @override
  void initState() {
    super.initState();
    _initializeAgent();
  }

  Future<void> _initializeAgent() async {
    // Configure your LLM provider
    final OpenAIProvider llmProvider = OpenAIProvider(
      apiKey: 'your-api-key-here',
    );

    // Create agent configuration
    final AgentConfig config = AgentConfig(
      name: 'My AI Assistant',
      instructions: 'You are a helpful AI assistant.',
      llmProvider: llmProvider,
      tools: <Tool>[
        FunctionTool(
          name: 'get_weather',
          description: 'Get the current weather for a location',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, Map<String, String>>{
              'location': <String, String>{
                'type': 'string',
                'description': 'The city name',
              },
            },
            'required': <String>['location'],
          },
          function: (final Map<String, dynamic> args) async {
            final location = args['location'];
            return <String, dynamic>{
              'temperature': 72,
              'condition': 'sunny',
              'location': location
            };
          },
        ),
      ],
    );

    _agent = VoiceAgent(config: config);

    // Create session
    _session = await _agent.createSession();

    // Listen to state changes
    _session!.state.listen((final SessionStatus status) {
      setState(() {
        _status = status;
      });
    });

    // Listen to messages
    _session!.messages.listen((final List<Message> messages) {
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
    });
  }

  Future<void> _sendMessage(final String text) async {
    if (_session == null) return;
    await _session!.sendMessage(text);
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('AI Agent Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(8),
              color: _getStatusColor(),
              child: Row(
                children: [
                  Icon(_getStatusIcon(), color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _status.state.name.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Messages list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.role == MessageRole.user;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(message.content),
                    ),
                  );
                },
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () async {
                      if (_session != null) {
                        await _session!.startListening();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Color _getStatusColor() {
    switch (_status.state) {
      case SessionState.idle:
        return Colors.grey;
      case SessionState.listening:
        return Colors.blue;
      case SessionState.processing:
        return Colors.orange;
      case SessionState.speaking:
        return Colors.green;
      case SessionState.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_status.state) {
      case SessionState.idle:
        return Icons.circle;
      case SessionState.listening:
        return Icons.mic;
      case SessionState.processing:
        return Icons.hourglass_empty;
      case SessionState.speaking:
        return Icons.volume_up;
      case SessionState.error:
        return Icons.error;
    }
  }

  @override
  void dispose() {
    _agent.closeSession();
    super.dispose();
  }
}
