# Configuration Guide

Complete guide to configuring the Flutter AI Agent SDK for your specific needs.

## Agent Configuration

The `AgentConfig` class is the central configuration object for your AI agent.

```dart
final config = AgentConfig(
  name: 'My Assistant',
  instructions: 'You are a helpful AI assistant.',
  llmProvider: llmProvider,
  sttService: sttService,
  ttsService: ttsService,
  turnDetection: turnDetectionConfig,
  tools: customTools,
  memoryConfig: memoryConfig,
);
```

## Core Configuration Options

### Basic Information

```dart
AgentConfig(
  name: 'Assistant Name',           // Name of your agent
  instructions: 'Your system prompt', // How the agent should behave
  version: '1.0.0',                // Agent version (optional)
  metadata: {                      // Additional metadata (optional)
    'author': 'Your Name',
    'purpose': 'Task description',
  },
)
```

### LLM Provider Configuration

```dart
llmProvider: OpenAIProvider(
  apiKey: 'your-api-key',
  model: 'gpt-4-turbo-preview',
  temperature: 0.7,
  maxTokens: 1000,
  timeout: Duration(seconds: 30),
  baseUrl: 'https://api.openai.com/v1', // Optional custom endpoint
),
```

### Speech Services

```dart
sttService: NativeSTTService(
  language: 'en-US',
  continuous: true,
  enableAutomaticPunctuation: true,
  maxAlternatives: 1,
),

ttsService: NativeTTSService(
  language: 'en-US',
  voice: 'en-us-x-sfg#female_1', // Platform-specific voice
  rate: 0.5,                     // Speech rate (0.0 - 1.0)
  pitch: 1.0,                    // Voice pitch (0.0 - 2.0)
  volume: 0.8,                   // Volume (0.0 - 1.0)
),
```

### Turn Detection Configuration

```dart
turnDetection: TurnDetectionConfig(
  mode: TurnDetectionMode.vad,     // vad, pushToTalk, serverVAD, hybrid
  silenceThreshold: Duration(milliseconds: 700), // Silence before ending turn
  prefixPaddingMs: 300,            // Padding before speech starts
  silenceDurationMs: 800,          // Minimum silence duration

  // VAD-specific settings
  vadThreshold: 0.5,               // Voice activity threshold (0.0 - 1.0)
  vadBufferSize: 1024,             // Audio buffer size

  // Push-to-talk settings
  pushToTalkKey: LogicalKeyboardKey.space, // Key to trigger listening

  // Server VAD settings (for OpenAI Realtime)
  serverVadEnabled: true,
  serverVadThreshold: 0.5,
),
```

## Advanced Configuration

### Memory Configuration

```dart
memoryConfig: MemoryConfig(
  maxShortTermMessages: 50,        // Max messages in short-term memory
  maxLongTermSummaries: 100,       // Max conversation summaries
  memoryPersistence: MemoryPersistence.file, // file, database, memory
  memoryPath: 'path/to/memory.db', // Path for persistent storage
  compressionEnabled: true,        // Enable memory compression
  compressionThreshold: 1000,      // Messages before compression
),
```

### Tool Configuration

```dart
tools: [
  FunctionTool(
    name: 'get_weather',
    description: 'Get current weather for a location',
    parameters: {
      'type': 'object',
      'properties': {
        'location': {'type': 'string'},
        'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
      },
      'required': ['location'],
    },
    function: (args) async {
      // Your tool implementation
      return {'temperature': 22, 'condition': 'sunny'};
    },
  ),
],
```

### Logging Configuration

```dart
loggingConfig: LoggingConfig(
  level: LogLevel.info,            // debug, info, warning, error
  enableConsoleLogging: true,
  enableFileLogging: true,
  logFilePath: 'path/to/logs/',
  maxLogFileSize: 10 * 1024 * 1024, // 10MB
  maxLogFiles: 5,
  includeStackTrace: true,
),
```

### Audio Configuration

```dart
audioConfig: AudioConfig(
  sampleRate: 16000,               // Audio sample rate
  channels: 1,                     // Mono audio
  bitDepth: 16,                    // Audio bit depth
  bufferSize: 4096,                // Audio buffer size

  // Recording settings
  recordingFormat: AudioFormat.wav,
  enableNoiseReduction: true,
  enableEchoCancellation: true,

  // Playback settings
  playbackVolume: 0.8,
  enablePlaybackSpeedControl: true,
),
```

## Provider-Specific Configuration

### OpenAI Configuration

```dart
OpenAIProvider(
  apiKey: 'sk-...',
  model: 'gpt-4-turbo-preview',

  // Request parameters
  temperature: 0.7,
  maxTokens: 1000,
  topP: 1.0,
  frequencyPenalty: 0.0,
  presencePenalty: 0.0,

  // Advanced settings
  timeout: Duration(seconds: 30),
  maxRetries: 3,
  retryDelay: Duration(milliseconds: 1000),

  // Custom base URL (for proxies)
  baseUrl: 'https://api.openai.com/v1',

  // Organization ID (for team accounts)
  organization: 'org-...',
)
```

### Anthropic Configuration

```dart
AnthropicProvider(
  apiKey: 'sk-ant-api03-...',
  model: 'claude-3-sonnet-20240229',

  // Request parameters
  temperature: 0.7,
  maxTokens: 1000,
  topP: 0.9,
  topK: 40,

  // Timeout and retry settings
  timeout: Duration(seconds: 30),
  maxRetries: 3,

  // Custom endpoint
  baseUrl: 'https://api.anthropic.com',
)
```

## Environment-Based Configuration

For different environments (development, staging, production):

```dart
class AppConfig {
  static AgentConfig getConfig() {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    switch (environment) {
      case 'production':
        return _getProductionConfig();
      case 'staging':
        return _getStagingConfig();
      default:
        return _getDevelopmentConfig();
    }
  }

  static AgentConfig _getDevelopmentConfig() {
    return AgentConfig(
      name: 'Dev Assistant',
      instructions: 'You are in development mode.',
      // ... development settings
    );
  }

  static AgentConfig _getProductionConfig() {
    return AgentConfig(
      name: 'Production Assistant',
      instructions: 'You are in production mode.',
      // ... production settings
    );
  }
}
```

## Configuration Validation

Always validate your configuration before using it:

```dart
try {
  final config = AgentConfig(/* your config */);
  config.validate(); // Throws if invalid

  final agent = VoiceAgent(config: config);
} catch (e) {
  print('Configuration error: $e');
}
```

## Best Practices

1. **Environment Variables**: Store API keys and sensitive data in environment variables
2. **Validation**: Always validate configurations in development
3. **Logging**: Enable appropriate logging levels for each environment
4. **Error Handling**: Implement proper error handling for configuration failures
5. **Testing**: Test configurations across different environments

## Troubleshooting

### Common Configuration Issues

**Invalid API Key**
- Verify the API key format and permissions
- Check if the key is expired or revoked

**Audio Permissions**
- Ensure microphone permissions are properly configured
- Check platform-specific permission requirements

**Memory Issues**
- Adjust memory settings based on device capabilities
- Monitor memory usage in production

**Performance Issues**
- Tune audio buffer sizes and sample rates
- Adjust LLM parameters for optimal performance
