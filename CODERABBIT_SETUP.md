# CodeRabbit Setup Guide

## Overview
CodeRabbit is an AI-powered code review tool that provides deep analysis of pull requests.

## Installation Steps

### 1. Install CodeRabbit GitHub App

1. Go to [CodeRabbit GitHub App](https://github.com/apps/coderabbitai)
2. Click **Install** or **Configure**
3. Select your GitHub account: **Chief-Strategist-J**
4. Choose repository access:
   - Select **Only select repositories**
   - Choose: `flutter_ai_agent_sdk`
5. Click **Install** or **Save**

### 2. Configure Repository Settings

The `.coderabbit.yaml` configuration is already in your repository with:

#### Enabled Features
- ✅ Comprehensive code review
- ✅ Security vulnerability detection
- ✅ Test coverage analysis
- ✅ Documentation completeness check
- ✅ Performance issue detection
- ✅ Memory leak detection
- ✅ Type safety verification
- ✅ Error handling review

#### Review Focus Areas
1. **Critical** (Zero Tolerance)
   - Security vulnerabilities
   - Memory leaks
   - Null safety violations

2. **High Priority**
   - API documentation (100% required)
   - Test coverage (100% required)
   - Type safety
   - Error handling
   - Resource management

3. **Code Quality**
   - Cyclomatic complexity (max 10)
   - Code duplication (max 5%)
   - Naming conventions
   - Performance issues

#### Path-Specific Rules
- `lib/**/*.dart` - Strict production code rules
- `test/**/*.dart` - Test quality enforcement
- `lib/src/core/**/*.dart` - Architecture patterns
- `lib/src/llm/**/*.dart` - API security & rate limiting
- `lib/src/voice/**/*.dart` - Resource management
- `lib/src/memory/**/*.dart` - Memory safety

### 3. Verify Installation

After installing:

1. Create a test PR to verify CodeRabbit is active
2. CodeRabbit should comment within 1-2 minutes
3. Look for greeting message from @coderabbitai

### 4. Integration with CI/CD

CodeRabbit automatically integrates with:
- ✅ GitHub Actions (your CI workflow)
- ✅ Codecov (coverage reporting)
- ✅ GitHub pull requests

### 5. Using CodeRabbit

#### Automatic Review
CodeRabbit automatically reviews:
- Every new pull request
- Every push to an open PR
- Draft PRs (if enabled)

#### Manual Commands
In PR comments, you can use:
```
@coderabbitai review
```
Request a full review

```
@coderabbitai help
```
Get help with CodeRabbit commands

```
@coderabbitai pause
```
Pause reviews temporarily

```
@coderabbitai resume
```
Resume reviews

#### Pull Request Checklist
CodeRabbit enforces:
- [ ] Tests added for new functionality
- [ ] All tests passing
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Code follows analysis_options.yaml
- [ ] 100% code coverage maintained
- [ ] No TODO/FIXME comments
- [ ] All public APIs documented
- [ ] Error handling comprehensive
- [ ] Resources properly disposed

### 6. Quality Gates

CodeRabbit will **block merge** if:
- Test coverage < 100% (configurable threshold)
- Security vulnerabilities found
- Critical bugs present
- Missing documentation

CodeRabbit will **warn** but not block if:
- Code complexity high
- Code duplication detected
- Performance concerns present

### 7. Review Process

#### For Pull Request Authors
1. Create PR with proper description (min 100 chars)
2. Link related issue
3. Wait for CodeRabbit review (1-2 minutes)
4. Address all critical issues
5. Respond to suggestions
6. Request re-review after changes

#### For Maintainers
1. CodeRabbit reviews first (automated)
2. Human review after CodeRabbit approval
3. Merge only when both approve

### 8. Configuration Customization

The `.coderabbit.yaml` can be customized per your needs:

```yaml
# Adjust coverage threshold
checks:
  - name: test_coverage
    min_coverage: 100%  # Change to 80%, 90%, etc.

# Adjust complexity threshold
checks:
  - name: code_complexity
    max_cyclomatic: 10  # Increase if needed

# Modify path-specific rules
path_instructions:
  - path: "lib/**/*.dart"
    instructions: |
      Your custom instructions here
```

### 9. Monitoring & Reports

CodeRabbit provides:
- Per-PR review summaries
- Security vulnerability reports
- Coverage trend analysis
- Code quality metrics
- Performance insights

Access reports:
- In PR comments
- On CodeRabbit dashboard
- Via email notifications (if configured)

### 10. Best Practices

#### Before Opening PR
1. Run local tests: `./test_local.sh`
2. Ensure coverage ≥ 80%
3. Fix all lint errors: `flutter analyze`
4. Format code: `dart format .`

#### During Review
1. Address critical issues immediately
2. Discuss suggestions constructively
3. Ask CodeRabbit for clarification if needed
4. Update tests for new edge cases

#### After Approval
1. Squash commits if requested
2. Update CHANGELOG.md
3. Merge using appropriate strategy
4. Monitor post-merge CI

### 11. Troubleshooting

#### CodeRabbit Not Commenting
- Verify app is installed correctly
- Check repository permissions
- Ensure PR is not from a fork (security restriction)
- Wait 5 minutes, then request manual review

#### False Positives
- Use `.coderabbit.yaml` to adjust rules
- Comment with explanation in PR
- Request human review override

#### Too Strict Rules
- Adjust thresholds in `.coderabbit.yaml`
- Disable specific rules if not applicable
- Balance between quality and velocity

### 12. Cost & Pricing

CodeRabbit offers:
- **Free Tier**: For public repositories (this project qualifies!)
- **Pro Tier**: For private repositories
- **Enterprise**: For organizations

As a public open-source project, you get **full access for free**.

### 13. Support

Need help?
- [CodeRabbit Docs](https://docs.coderabbit.ai)
- GitHub Issues: Report bugs/feature requests
- Community: Join CodeRabbit Discord
- Email: [support@coderabbit.ai](mailto:support@coderabbit.ai)

## Summary
{{ ... }}
1. Install CodeRabbit GitHub App
2. Configuration already in `.coderabbit.yaml`
4. ✅ Create PR to test
5. ✅ Enjoy automated deep code reviews!

## Next Steps

1. Install the CodeRabbit GitHub App now
2. Create a small test PR to verify it works
3. Start using it for all future PRs
4. Monitor quality improvements over time
