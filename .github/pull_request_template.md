## Description
<!-- Provide a clear and concise description of the changes (minimum 100 characters) -->



## Related Issue
<!-- Link to the issue this PR addresses -->
Closes #

## Type of Change
<!-- Mark the relevant option with an 'x' -->
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring
- [ ] ⚡ Performance improvement
- [ ] ✅ Test addition/improvement

## Testing
<!-- Describe the tests you ran and how to reproduce them -->

### Test Coverage
- Current coverage: __%
- Target coverage: 100%
- Coverage change: ±__%

### Tests Added
<!-- List the test files/scenarios added -->
- [ ]

### Manual Testing
<!-- Describe manual testing steps if applicable -->
1.

## Checklist
<!-- Ensure all items are completed before requesting review -->

### Code Quality
- [ ] ✅ All tests pass locally (`./test_local.sh`)
- [ ] 📊 Code coverage ≥ 80% (check `coverage/html/index.html`)
- [ ] 📝 All public APIs have documentation comments (`///`)
- [ ] 🎨 Code is properly formatted (`dart format .`)
- [ ] 🔍 Analysis passes with no errors (`flutter analyze --fatal-infos`)
- [ ] 🚫 No TODO/FIXME comments in production code
- [ ] 📦 All imports are sorted alphabetically
- [ ] 🎯 All types are explicitly annotated
- [ ] 🔒 All parameters are marked as `final`
- [ ] 🧹 No unused imports or variables

### Testing
- [ ] ✅ Tests added for new functionality
- [ ] 🧪 Tests cover edge cases (null, empty, boundary values)
- [ ] 🚨 Tests cover error scenarios
- [ ] ♻️ Tests use proper arrange-act-assert structure
- [ ] 🔄 Async tests properly use `async`/`await`
- [ ] 🧼 Tests properly clean up resources (dispose, close)
- [ ] 🎭 External dependencies are mocked

### Documentation
- [ ] 📖 README.md updated (if applicable)
- [ ] 📋 CHANGELOG.md updated with changes
- [ ] 📚 Public API documented with examples
- [ ] 🔧 Configuration changes documented
- [ ] ⚠️ Breaking changes clearly documented

### Architecture
- [ ] 🏗️ Follows Clean Architecture principles
- [ ] 🔌 Uses dependency injection
- [ ] 📦 No hardcoded values or magic numbers
- [ ] 🎯 Single Responsibility Principle followed
- [ ] 🔄 Proper separation of concerns
- [ ] 💾 Resources properly disposed (close/dispose methods)

### Security & Performance
- [ ] 🔐 No sensitive data exposed (API keys, secrets)
- [ ] ⚡ No performance regressions
- [ ] 💾 No memory leaks (streams closed, controllers disposed)
- [ ] 🔒 Proper error handling implemented
- [ ] 🛡️ Input validation where needed

### Package
- [ ] 📦 `pubspec.yaml` updated (if dependencies changed)
- [ ] 🔢 Version number updated (if applicable)
- [ ] ✅ Package can be published (`dart pub publish --dry-run`)
- [ ] 📄 License information correct
- [ ] 🏷️ Package metadata accurate

## Breaking Changes
<!-- If this PR introduces breaking changes, describe them here -->
<!-- Provide migration guide for users -->

None / See below:



## Screenshots (if applicable)
<!-- Add screenshots for UI changes -->



## Additional Context
<!-- Add any other context about the PR here -->



## Reviewer Notes
<!-- Any specific areas you want reviewers to focus on? -->



---

## CodeRabbit Review
<!-- CodeRabbit will automatically review this PR -->
<!-- Address all critical issues before requesting human review -->

- [ ] CodeRabbit review completed
- [ ] All critical issues addressed
- [ ] All suggestions reviewed and responded to

## Local Test Results
<!-- Paste output from `./test_local.sh` or summarize -->

```bash
# Run: ./test_local.sh
# Paste relevant summary here
```

---

**By submitting this PR, I confirm that:**
- All checks above are completed
- Code follows the project's style guide and `analysis_options.yaml`
- Tests achieve the required coverage
- Documentation is complete and accurate
- No breaking changes (or properly documented)
