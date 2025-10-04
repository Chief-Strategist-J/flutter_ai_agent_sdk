#!/bin/bash
set -e

echo "🚀 Setting up Flutter AI Agent SDK..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation
echo "🔨 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Update API keys in example/main.dart"
echo "2. Run: cd $PROJECT && flutter run"
echo "3. See README.md for documentation"
