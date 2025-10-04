#!/usr/bin/env python3
"""
Enhanced Wiki Sync Script with Better Structure
"""

import os
import shutil
import re
from pathlib import Path
from typing import List, Dict, Tuple

class EnhancedWikiSync:
    def __init__(self, docs_dir: str = "docs", wiki_dir: str = "wiki"):
        self.docs_dir = Path(docs_dir)
        self.wiki_dir = Path(wiki_dir)
        self.sidebar_content = []

    def clean_wiki_dir(self):
        """Clean the wiki directory while preserving git history."""
        if self.wiki_dir.exists():
            for item in self.wiki_dir.iterdir():
                if item.is_file() and item.name not in ['.git', 'Home.md', '_Sidebar.md']:
                    item.unlink()
                elif item.is_dir() and item.name != '.git':
                    shutil.rmtree(item)

    def copy_docs_to_wiki(self):
        """Copy and convert documentation files to wiki format."""
        if not self.docs_dir.exists():
            print(f"Docs directory {self.docs_dir} does not exist!")
            return

        # Copy all files and directories
        for item in self.docs_dir.rglob('*'):
            if item.is_file() and item.suffix.lower() in ['.md', '.markdown']:
                relative_path = item.relative_to(self.docs_dir)
                wiki_path = self.wiki_dir / relative_path

                # Create parent directory if it doesn't exist
                wiki_path.parent.mkdir(parents=True, exist_ok=True)

                # Convert and copy file
                self._convert_and_copy_file(item, wiki_path)
                print(f"Copied: {relative_path}")

    def _convert_and_copy_file(self, source: Path, destination: Path):
        """Convert markdown file for wiki format."""
        with open(source, 'r', encoding='utf-8') as f:
            content = f.read()

        # Convert relative links to wiki format
        content = self._convert_links_for_wiki(content)

        # Add wiki metadata if needed
        content = self._add_wiki_metadata(content, source)

        with open(destination, 'w', encoding='utf-8') as f:
            f.write(content)

    def _convert_links_for_wiki(self, content: str) -> str:
        """Convert relative links to wiki-compatible format."""
        # Pattern to match relative links like [](path/to/file.md)
        link_pattern = r'\[([^\]]*)\]\(([^)]+)\)'

        def update_link(match):
            text, link = match.groups()

            # Convert relative paths to wiki format
            if link.startswith('./') or link.startswith('../'):
                # Remove leading ./ and convert to wiki format
                if link.startswith('./'):
                    wiki_link = link[2:]
                elif link.startswith('../'):
                    wiki_link = link[3:]
                else:
                    wiki_link = link

                # Convert .md extensions to wiki format (no extension needed)
                if wiki_link.endswith('.md'):
                    wiki_link = wiki_link[:-3]

                return f"[{text}]({wiki_link})"

            return match.group(0)

        return re.sub(link_pattern, update_link, content)

    def _add_wiki_metadata(self, content: str, source: Path) -> str:
        """Add wiki-specific metadata to the content."""
        # Add front matter for better organization
        front_matter = f"""---
title: {source.stem}
description: Documentation for {source.stem}
---

"""
        return front_matter + content

    def create_homepage(self):
        """Create an enhanced wiki homepage."""
        homepage_path = self.wiki_dir / "Home.md"

        content = """# Flutter AI Agent SDK Documentation

Welcome to the comprehensive documentation for the Flutter AI Agent SDK!

## 🚀 Quick Start

Get started with Flutter AI Agent SDK in minutes:

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

### 🏠 Getting Started
- **[Quick Start](getting-started-quick-start)** - Get up and running in minutes
- **[Installation](getting-started-installation)** - Installation and setup
- **[Configuration](getting-started-configuration)** - Configuration options

### 🔧 Core Concepts
- **[Agents](core-concepts-agents)** - Understanding the agent system
- **[Sessions](core-concepts-sessions)** - Session management
- **[Events](core-concepts-events)** - Event-driven architecture
- **[Memory](core-concepts-memory)** - Memory management strategies

### 🎙️ Voice Features
- **[Speech-to-Text](voice-features-speech-to-text)** - STT integration guide
- **[Text-to-Speech](voice-features-text-to-speech)** - TTS integration guide
- **[Voice Activity Detection](voice-features-voice-activity-detection)** - VAD system
- **[Turn Detection](voice-features-turn-detection)** - Turn detection modes

### 🤖 LLM Integration
- **[Supported Providers](llm-integration-providers)** - Available LLM providers
- **[OpenAI Setup](llm-integration-openai-setup)** - OpenAI integration
- **[Anthropic Setup](llm-integration-anthropic-setup)** - Anthropic integration
- **[Custom Providers](llm-integration-custom-providers)** - Build custom providers

### 🛠️ Advanced Features
- **[Custom Tools](advanced-features-custom-tools)** - Create custom functions
- **[Function Calling](advanced-features-function-calling)** - Advanced function calling
- **[Error Handling](advanced-features-error-handling)** - Robust error handling

### 📱 Platform Support
- **[iOS Guide](platform-support-ios)** - iOS-specific setup
- **[Android Guide](platform-support-android)** - Android-specific setup
- **[Web Support](platform-support-web)** - Web platform guide

### 📖 API Reference
- **[Complete API Reference](api-reference)** - Detailed API documentation

## 🌟 Key Features

- **🎙️ Voice Interaction**: Native STT/TTS support across platforms
- **🤖 Multi-LLM Support**: OpenAI, Anthropic, and custom providers
- **🛠️ Function Calling**: Execute custom functions from AI responses
- **💾 Memory Management**: Short-term and long-term conversation memory
- **🔄 Real-time Streaming**: Live response streaming
- **🎯 Smart Turn Detection**: VAD, push-to-talk, and hybrid modes
- **📦 Pure Dart**: No platform-specific code required
- **⚡ High Performance**: Optimized for mobile devices

## 🆘 Getting Help

- **📧 Email**: [chief.stategist.j@gmail.com](mailto:chief.stategist.j@gmail.com)
- **🐛 Issues**: [GitHub Issues](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/discussions)

## 📄 License

This project is licensed under the MIT License.

---
*Made with ❤️ by Chief Strategist J*
"""

        with open(homepage_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print("Created enhanced: Home.md")

    def generate_sidebar(self):
        """Generate enhanced sidebar content for better navigation."""
        sidebar = self._generate_navigation_structure()
        sidebar_path = self.wiki_dir / "_Sidebar.md"

        with open(sidebar_path, 'w', encoding='utf-8') as f:
            f.write(sidebar)

        print("Created enhanced: _Sidebar.md")

    def _generate_navigation_structure(self) -> str:
        """Generate comprehensive navigation structure for the sidebar."""
        navigation = """# 📚 Documentation

## 🏠 Getting Started
- [Quick Start](getting-started-quick-start)
- [Installation](getting-started-installation)
- [Configuration](getting-started-configuration)
- [First Agent](getting-started-first-agent)

## 🔧 Core Concepts
- [Agents](core-concepts-agents)
- [Sessions](core-concepts-sessions)
- [Events](core-concepts-events)
- [Memory](core-concepts-memory)
- [Tools](core-concepts-tools)

## 🎙️ Voice Features
- [Speech-to-Text](voice-features-speech-to-text)
- [Text-to-Speech](voice-features-text-to-speech)
- [Voice Activity Detection](voice-features-voice-activity-detection)
- [Turn Detection](voice-features-turn-detection)
- [Audio Processing](voice-features-audio-processing)

## 🤖 LLM Integration
- [LLM Providers](llm-integration-providers)
- [OpenAI Setup](llm-integration-openai-setup)
- [Anthropic Setup](llm-integration-anthropic-setup)
- [Custom Providers](llm-integration-custom-providers)
- [Streaming](llm-integration-streaming)

## 🛠️ Advanced Features
- [Custom Tools](advanced-features-custom-tools)
- [Function Calling](advanced-features-function-calling)
- [Error Handling](advanced-features-error-handling)
- [Middleware](advanced-features-middleware)
- [Testing](advanced-features-testing)

## 📱 Platform Support
- [iOS Support](platform-support-ios)
- [Android Support](platform-support-android)
- [Web Support](platform-support-web)
- [Desktop Support](platform-support-desktop)

## 🚢 Deployment
- [Deployment Guide](deployment-deployment-guide)
- [CI/CD Setup](deployment-ci-cd)
- [Publishing](deployment-publishing)

## 🤝 Contributing
- [Contributing Guide](contributing-contributing)
- [Development Setup](contributing-development-setup)
- [Code Standards](contributing-code-standards)

## 📖 API Reference
- [Complete API Reference](api-reference)

## 🆘 Support & Links
- [GitHub Issues](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/issues)
- [GitHub Discussions](https://github.com/Chief-Strategist-J/flutter_ai_agent_sdk/discussions)
- [Email Support](mailto:chief.stategist.j@gmail.com)

---
*Built with ❤️ for the Flutter community*
"""

        return navigation

    def run(self):
        """Run the complete enhanced sync process."""
        print("Starting enhanced wiki sync...")

        # Clean wiki directory
        self.clean_wiki_dir()

        # Copy documentation files
        self.copy_docs_to_wiki()

        # Create homepage
        self.create_homepage()

        # Generate sidebar
        self.generate_sidebar()

        print("Enhanced wiki sync completed successfully!")

def main():
    sync = EnhancedWikiSync()
    sync.run()

if __name__ == "__main__":
    main()
