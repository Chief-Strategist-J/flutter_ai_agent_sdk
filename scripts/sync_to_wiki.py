#!/usr/bin/env python3
"""
Wiki Sync Script

This script synchronizes the docs/ directory with the GitHub wiki.
It converts Markdown files to wiki-compatible format and organizes them properly.
"""

import os
import shutil
import re
from pathlib import Path
from typing import List, Dict, Tuple

class WikiSync:
    def __init__(self, docs_dir: str = "docs", wiki_dir: str = "wiki"):
        self.docs_dir = Path(docs_dir)
        self.wiki_dir = Path(wiki_dir)
        self.sidebar_content = []

    def clean_wiki_dir(self):
        """Clean the wiki directory while preserving git history."""
        if self.wiki_dir.exists():
            for item in self.wiki_dir.iterdir():
                if item.is_file() and item.name != '.git':
                    item.unlink()
                elif item.is_dir() and item.name != '.git':
                    shutil.rmtree(item)

    def copy_docs_to_wiki(self):
        """Copy documentation files to wiki directory."""
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

                # Copy file
                shutil.copy2(item, wiki_path)
                print(f"Copied: {relative_path}")

    def create_homepage(self):
        """Create the wiki homepage."""
        homepage_path = self.wiki_dir / "Home.md"

        if not self.docs_dir.exists():
            content = "# Flutter AI Agent SDK Wiki\n\nDocumentation is being generated..."
        else:
            # Use the main index.md as homepage
            index_path = self.docs_dir / "index.md"
            if index_path.exists():
                with open(index_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Update relative links to work in wiki
                content = self.update_links_for_wiki(content)
            else:
                content = "# Flutter AI Agent SDK Wiki\n\nWelcome to the documentation!"

        with open(homepage_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print("Created: Home.md")

    def update_links_for_wiki(self, content: str) -> str:
        """Update relative links to work in wiki context."""

        # Pattern to match relative links like [](path/to/file.md)
        link_pattern = r'\[([^\]]*)\]\(([^)]+)\)'

        def update_link(match):
            text, link = match.groups()

            # Convert relative paths to wiki-compatible paths
            if link.startswith('./') or link.startswith('../'):
                # For wiki, we need to adjust the path structure
                if link.startswith('./'):
                    # Remove leading ./ and convert to wiki format
                    wiki_link = link[2:]
                elif link.startswith('../'):
                    # Go up one level and convert
                    wiki_link = link[3:]
                else:
                    wiki_link = link

                # Convert .md extensions to wiki format (no extension needed)
                if wiki_link.endswith('.md'):
                    wiki_link = wiki_link[:-3]

                return f"[{text}]({wiki_link})"

            return match.group(0)

        return re.sub(link_pattern, update_link, content)

    def generate_sidebar(self):
        """Generate sidebar content for better navigation."""
        sidebar = self.generate_navigation_structure()
        sidebar_path = self.wiki_dir / "_Sidebar.md"

        with open(sidebar_path, 'w', encoding='utf-8') as f:
            f.write(sidebar)

        print("Created: _Sidebar.md")

    def generate_navigation_structure(self) -> str:
        """Generate navigation structure for the sidebar."""
        navigation = "# Documentation Navigation\n\n"

        if not self.docs_dir.exists():
            return navigation + "Documentation is being generated..."

        # Main sections
        main_sections = {
            "🏠 Getting Started": [
                "getting-started/quick-start.md",
                "getting-started/installation.md",
                "getting-started/configuration.md",
            ],
            "🔧 Core Concepts": [
                "core-concepts/agents.md",
                "core-concepts/sessions.md",
                "core-concepts/events.md",
                "core-concepts/memory.md",
            ],
            "🎙️ Voice Features": [
                "voice-features/speech-to-text.md",
                "voice-features/text-to-speech.md",
                "voice-features/voice-activity-detection.md",
            ],
            "🤖 LLM Integration": [
                "llm-integration/providers.md",
                "llm-integration/openai-setup.md",
                "llm-integration/anthropic-setup.md",
            ],
            "🛠️ Advanced Features": [
                "advanced-features/custom-tools.md",
                "advanced-features/function-calling.md",
            ],
            "📱 Platform Support": [
                "platform-support/ios.md",
                "platform-support/android.md",
                "platform-support/web.md",
            ],
            "📚 API Reference": [
                "api-reference.md",
            ],
        }

        for section, files in main_sections.items():
            navigation += f"## {section}\n\n"
            for file_path in files:
                if (self.docs_dir / file_path).exists():
                    # Convert path to wiki link
                    wiki_link = file_path.replace('.md', '').replace('/', '-')
                    title = file_path.split('/')[-1].replace('.md', '').replace('-', ' ').title()
                    navigation += f"- [{title}]({wiki_link})\n"
                else:
                    print(f"Warning: {file_path} not found")
            navigation += "\n"

        return navigation

    def run(self):
        """Run the complete sync process."""
        print("Starting wiki sync...")

        # Clean wiki directory
        self.clean_wiki_dir()

        # Copy documentation files
        self.copy_docs_to_wiki()

        # Create homepage
        self.create_homepage()

        # Generate sidebar
        self.generate_sidebar()

        print("Wiki sync completed successfully!")

def main():
    sync = WikiSync()
    sync.run()

if __name__ == "__main__":
    main()
