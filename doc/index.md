# Flutter AI Agent SDK Documentation

Welcome to the comprehensive documentation for the Flutter AI Agent SDK - a powerful, extensible framework for building AI-powered voice assistants in Flutter applications.

## 🌟 What is Flutter AI Agent SDK?

The Flutter AI Agent SDK is a comprehensive framework that enables developers to create sophisticated AI agents with voice interaction capabilities. It provides seamless integration with various Large Language Models (LLMs), speech-to-text, text-to-speech, and advanced conversation management features.

### ✨ Key Features

- **🎙️ Voice Interaction**: Native STT/TTS support across platforms
- **🤖 Multi-LLM Support**: OpenAI, Anthropic, and custom providers
- **🛠️ Function Calling**: Execute custom functions from AI responses
- **💾 Memory Management**: Short-term and long-term conversation memory
- **🔄 Real-time Streaming**: Live response streaming
- **🎯 Smart Turn Detection**: VAD, push-to-talk, and hybrid modes
- **📦 Pure Dart**: No platform-specific code required
- **⚡ High Performance**: Optimized for mobile devices

## 🚀 Quick Start

Get started in just a few lines of code:

```dart
import 'package:flutter_ai_agent_sdk/flutter_ai_agent_sdk.dart';

// 1. Create an LLM Provider
final llmProvider = OpenAIProvider(
  apiKey: 'your-api-key',
  model: 'gpt-4-turbo-preview',
);

// 2. Configure Your Agent
final config = AgentConfig(
  name: 'My Assistant',
  instructions: 'You are a helpful AI assistant.',
  llmProvider: llmProvider,
  sttService: NativeSTTService(),
  ttsService: NativeTTSService(),
);

// 3. Create and Use Agent
final agent = VoiceAgent(config: config);
final session = await agent.createSession();

await session.sendMessage('Hello!');
```

## 📚 Documentation Sections

### 🏠 [Getting Started](./getting-started/)
- **[Quick Start](./getting-started/quick-start.md)** - Get up and running in minutes
- **[Installation](./getting-started/installation.md)** - Installation and setup
- **[First Agent](./getting-started/first-agent.md)** - Create your first AI agent

### 🔧 [Core Concepts](./core-concepts/)
- **[Agents](./core-concepts/agents.md)** - Understanding the agent system
- **[Sessions](./core-concepts/sessions.md)** - Session management
- **[Events](./core-concepts/events.md)** - Event-driven architecture
- **[Memory](./core-concepts/memory.md)** - Memory management strategies

### 🎙️ [Voice Features](./voice-features/)
- **[Speech-to-Text](./voice-features/speech-to-text.md)** - STT integration guide
- **[Text-to-Speech](./voice-features/text-to-speech.md)** - TTS integration guide
- **[Voice Activity Detection](./voice-features/voice-activity-detection.md)** - VAD system
- **[Turn Detection](./voice-features/turn-detection.md)** - Turn detection modes

### 🤖 [LLM Integration](./llm-integration/)
- **[Supported Providers](./llm-integration/providers.md)** - Available LLM providers
- **[OpenAI Setup](./llm-integration/openai-setup.md)** - OpenAI integration
- **[Anthropic Setup](./llm-integration/anthropic-setup.md)** - Anthropic integration
- **[Custom Providers](./llm-integration/custom-providers.md)** - Build custom providers

### 🛠️ [Advanced Features](./advanced-features/)
- **[Custom Tools](./advanced-features/custom-tools.md)** - Create custom functions
- **[Function Calling](./advanced-features/function-calling.md)** - Advanced function calling
- **[Error Handling](./advanced-features/error-handling.md)** - Robust error handling

### 📱 [Platform Support](./platform-support/)
- **[iOS Guide](./platform-support/ios.md)** - iOS-specific setup
- **[Android Guide](./platform-support/android.md)** - Android-specific setup
- **[Web Support](./platform-support/web.md)** - Web platform guide

### 🧪 [Testing](./testing/)
- **[Testing Guide](./testing/testing-guide.md)** - Testing strategies
- **[Unit Tests](./testing/unit-tests.md)** - Writing unit tests
- **[Integration Tests](./testing/integration-tests.md)** - Integration testing

### 🚢 [Deployment](./deployment/)
- **[Deployment Guide](./deployment/deployment-guide.md)** - Deployment strategies
- **[CI/CD Setup](./deployment/ci-cd.md)** - Continuous integration

## 📖 API Reference

For detailed API documentation, see our [API Reference](./api-reference/) section.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./contributing/) for details.

## 🆘 Support

- **📧 Email**: [chief.stategist.j@gmail.com](mailto:chief.stategist.j@gmail.com)
- **📞 Phone**: [+91 9664920749](tel:+919664920749)
- **🐛 Issues**: [GitHub Issues](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Made with ❤️ by Chief Strategist J**
