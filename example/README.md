# Flutter AI Agent SDK - Complete Demo Application

A comprehensive demo application showcasing all features of the Flutter AI Agent SDK.

## Features Demonstrated

### 🎨 Basic Chat Page
- Simple text-based conversation with AI agent
- Message history display
- Error handling and status indicators
- Clean, modern UI

### 🎙️ Voice Chat Page
- Real-time voice interaction
- Visual feedback for listening/speaking states
- Voice activity detection
- Hands-free conversation experience

### 🛠️ Tools Demo Page
- Custom function/tool integration
- Weather queries, calculations, and time functions
- Tool execution visualization
- Interactive tool demonstrations

### ⚙️ Settings Page
- Configuration management
- API key setup
- Agent customization options
- Documentation and support links

## Getting Started

### Prerequisites

1. **Flutter SDK**: Version 3.10.0 or higher
2. **OpenAI API Key**: Get one from [OpenAI Platform](https://platform.openai.com)

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk.git
cd flutter_ai_agent_sdk
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Configure API Key**:

   Open `example/complete_demo.dart` and replace `'your-openai-api-key-here'` with your actual OpenAI API key:

```dart
final llmProvider = OpenAIProvider(
  apiKey: 'your-actual-openai-api-key',
  model: 'gpt-4-turbo-preview',
);
```

4. **Platform Setup**:

   **iOS**: Add microphone permissions to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to understand your voice commands.</string>
```

   **Android**: Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Running the Demo

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
```

## Project Structure

```
example/
├── complete_demo.dart       # Main demo application
├── main.dart               # Original simple example
└── README.md              # This file

lib/
├── src/
│   ├── core/              # Core agent functionality
│   ├── voice/             # Voice processing
│   ├── llm/               # LLM integration
│   ├── tools/             # Tool system
│   └── memory/            # Memory management
└── flutter_ai_agent_sdk.dart  # Main exports
```

## Demo Pages Explained

### 1. Basic Chat Page

**Purpose**: Demonstrates fundamental text-based AI interaction.

**Key Features**:
- Send/receive text messages
- Real-time conversation display
- Error handling and loading states
- Simple, intuitive interface

**Usage**:
```dart
// The page automatically initializes an agent and handles basic chat
// Users can type messages and receive AI responses
```

### 2. Voice Chat Page

**Purpose**: Shows voice interaction capabilities.

**Key Features**:
- Push-to-talk voice interface
- Real-time voice activity feedback
- Automatic speech recognition
- Text-to-speech responses

**Usage**:
```dart
// Tap microphone button to start/stop listening
// Speak naturally to interact with the AI
// Visual feedback shows listening/speaking states
```

### 3. Tools Demo Page

**Purpose**: Demonstrates custom tool/function integration.

**Available Tools**:
- **Weather**: Get current weather for locations
- **Calculator**: Perform mathematical calculations
- **Time**: Get current time for timezones

**Usage**:
```dart
// Ask questions like:
// "What's the weather in New York?"
// "What is 15 plus 27?"
// "What time is it in Tokyo?"
```

### 4. Settings Page

**Purpose**: Shows configuration and customization options.

**Features**:
- API key management
- Voice settings configuration
- Memory management options
- Documentation access

## Configuration Options

### Agent Configuration

The demo uses different configurations for each page:

```dart
// Basic chat configuration
AgentConfig(
  name: 'Demo Assistant',
  instructions: 'Be friendly and helpful',
  llmProvider: OpenAIProvider(apiKey: 'your-key'),
  // ... basic settings
)

// Voice chat configuration
AgentConfig(
  name: 'Voice Assistant',
  instructions: 'Speak naturally and conversationally',
  // ... voice-specific settings
)

// Tools configuration
AgentConfig(
  name: 'Tools Assistant',
  instructions: 'Use available tools to help users',
  tools: [weatherTool, calculatorTool, timeTool],
  // ... tool-specific settings
)
```

### Memory Settings

```dart
MemoryConfig(
  maxShortTermMessages: 50,        // Keep recent conversation
  maxLongTermSummaries: 10,        // Summarize important info
  persistence: MemoryPersistence.memory, // In-memory storage
)
```

### Voice Settings

```dart
TurnDetectionConfig(
  mode: TurnDetectionMode.vad,     // Voice Activity Detection
  silenceThreshold: Duration(milliseconds: 700),
)

NativeSTTService(
  language: 'en-US',
  continuous: false,               // Single utterance mode
)

NativeTTSService(
  language: 'en-US',
  rate: 0.5,                       // Moderate speech rate
  pitch: 1.0,
)
```

## Customization

### Adding New Tools

1. Create a new `FunctionTool`:

```dart
final newTool = FunctionTool(
  name: 'my_custom_tool',
  description: 'Description of what the tool does',
  parameters: {
    'type': 'object',
    'properties': {
      'param1': {'type': 'string'},
    },
    'required': ['param1'],
  },
  function: (args) async {
    // Your tool implementation
    return {'result': 'tool output'};
  },
);
```

2. Add to agent configuration:

```dart
AgentConfig(
  tools: [newTool, ...existingTools],
  // ... other config
)
```

### Customizing UI

The demo uses standard Flutter widgets but can be customized:

```dart
// Custom message bubble
class CustomMessageWidget extends StatelessWidget {
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: message.role == 'user' ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Text(message.content ?? ''),
    );
  }
}
```

## Troubleshooting

### Common Issues

**Microphone Permission Denied**
- iOS: Check Info.plist permissions
- Android: Check manifest permissions
- Grant permission when prompted

**API Key Issues**
- Verify API key is valid and has credits
- Check OpenAI account billing status
- Ensure correct API key format

**Voice Recognition Not Working**
- Check microphone hardware
- Verify internet connection
- Check device language settings

**Build Errors**
- Run `flutter clean && flutter pub get`
- Update Flutter SDK if needed
- Check for platform-specific issues

### Getting Help

- **📧 Email**: [chief.stategist.j@gmail.com](mailto:chief.stategist.j@gmail.com)
- **🐛 Issues**: [GitHub Issues](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/discussions)

## Advanced Usage

### Multiple Agents

```dart
class MultiAgentManager {
  final List<VoiceAgent> _agents = [];

  Future<VoiceAgent> createSpecializedAgent(String specialization) async {
    final config = await _createConfigForSpecialization(specialization);
    final agent = VoiceAgent(config: config);
    _agents.add(agent);
    return agent;
  }
}
```

### Custom Memory Management

```dart
class CustomMemoryManager {
  Future<void> implementCustomPersistence() async {
    // Custom database storage
    // Custom compression algorithms
    // Custom retrieval strategies
  }
}
```

## Performance Tips

### Memory Optimization
- Use appropriate memory limits for your use case
- Implement memory compression for long conversations
- Clear old messages periodically

### Audio Optimization
- Choose appropriate audio buffer sizes
- Optimize sample rates for target devices
- Handle audio interruptions gracefully

### Network Optimization
- Implement request batching
- Use streaming for real-time responses
- Handle network failures gracefully

## Contributing

We welcome contributions to improve the demo application!

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Test thoroughly
5. Submit a pull request

## License

This demo application is part of the Flutter AI Agent SDK and is licensed under the MIT License.

---

**Made with ❤️ by Chief Strategist J**

For more information about the Flutter AI Agent SDK, visit the [main documentation](../README.md).
