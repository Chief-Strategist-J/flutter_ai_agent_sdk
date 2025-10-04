#!/bin/bash

# Flutter AI Agent SDK - Local Testing Script with Detailed Error Logging
# This script provides comprehensive testing with detailed error logs

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓ [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}✗ [ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════${NC}"
    echo ""
}

# Create logs directory
LOGS_DIR="test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOGS_DIR}/test_run_${TIMESTAMP}.log"

mkdir -p "${LOGS_DIR}"
mkdir -p "coverage"

# Redirect all output to log file and console
exec > >(tee -a "${LOG_FILE}")
exec 2>&1

log_section "Flutter AI Agent SDK - Comprehensive Testing"

log_info "Test run started at: $(date)"
log_info "Log file: ${LOG_FILE}"

# Check Flutter installation
log_section "1. Environment Setup"

if ! command -v flutter &> /dev/null; then
    log_error "Flutter is not installed or not in PATH"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
log_info "Flutter version: ${FLUTTER_VERSION}"

# Check Dart installation
if ! command -v dart &> /dev/null; then
    log_error "Dart is not installed or not in PATH"
    exit 1
fi

DART_VERSION=$(dart --version 2>&1 | head -n 1)
log_info "Dart version: ${DART_VERSION}"

log_success "Environment setup complete"

# Clean previous build artifacts
log_section "2. Cleaning Build Artifacts"

log_info "Removing previous build artifacts..."
flutter clean > /dev/null 2>&1 || true
rm -rf .dart_tool/build
rm -rf build/
rm -rf coverage/lcov.info
log_success "Build artifacts cleaned"

# Get dependencies
log_section "3. Installing Dependencies"

log_info "Running flutter pub get..."
if flutter pub get; then
    log_success "Dependencies installed successfully"
else
    log_error "Failed to install dependencies"
    exit 1
fi

# Verify package structure
log_section "4. Package Structure Verification"

log_info "Checking required files..."
REQUIRED_FILES=("pubspec.yaml" "README.md" "CHANGELOG.md" "LICENSE" "lib/flutter_ai_agent_sdk.dart")

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_success "Found: $file"
    else
        log_error "Missing required file: $file"
        exit 1
    fi
done

# Code formatting check
log_section "5. Code Formatting Check"

log_info "Checking code formatting..."
if dart format --output=none --set-exit-if-changed .; then
    log_success "All files are properly formatted"
else
    log_error "Some files are not properly formatted"
    log_info "Run 'dart format .' to fix formatting issues"
    exit 1
fi

# Static analysis
log_section "6. Static Analysis"

log_info "Running static analysis with strict rules..."
ANALYSIS_LOG="${LOGS_DIR}/analysis_${TIMESTAMP}.log"

if flutter analyze --fatal-infos --fatal-warnings 2>&1 | tee "${ANALYSIS_LOG}"; then
    log_success "Static analysis passed"
else
    log_error "Static analysis failed"
    log_error "See detailed errors in: ${ANALYSIS_LOG}"
    
    # Show top errors
    log_info "Top analysis errors:"
    grep -E "error •|warning •" "${ANALYSIS_LOG}" | head -n 10 || true
    exit 1
fi

# Check for TODO/FIXME
log_section "7. TODO/FIXME Check"

log_info "Checking for TODO/FIXME in production code..."
TODO_LOG="${LOGS_DIR}/todo_check_${TIMESTAMP}.log"

if grep -r "TODO\|FIXME" lib/ > "${TODO_LOG}" 2>&1; then
    log_error "Found TODO/FIXME in production code:"
    cat "${TODO_LOG}"
    exit 1
else
    log_success "No TODO/FIXME found in production code"
fi

# Run tests with coverage
log_section "8. Running Tests with Coverage"

log_info "Running all tests with coverage..."
TEST_LOG="${LOGS_DIR}/test_output_${TIMESTAMP}.log"

if flutter test \
    --coverage \
    --test-randomize-ordering-seed=random \
    --reporter=expanded \
    --coverage-path=coverage/lcov.info 2>&1 | tee "${TEST_LOG}"; then
    log_success "All tests passed"
else
    log_error "Some tests failed"
    log_error "See detailed test output in: ${TEST_LOG}"
    
    # Extract failed tests
    log_info "Failed tests:"
    grep -E "FAILED|Error:|Exception:" "${TEST_LOG}" | head -n 20 || true
    exit 1
fi

# Generate coverage report
log_section "9. Coverage Analysis"

if [ ! -f "coverage/lcov.info" ]; then
    log_error "Coverage file not generated"
    exit 1
fi

log_info "Analyzing code coverage..."

# Install lcov if not present
if ! command -v lcov &> /dev/null; then
    log_warning "lcov not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install lcov
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y lcov
    else
        log_error "Please install lcov manually for your OS"
        exit 1
    fi
fi

# Generate detailed coverage report
COVERAGE_LOG="${LOGS_DIR}/coverage_${TIMESTAMP}.log"
lcov --summary coverage/lcov.info 2>&1 | tee "${COVERAGE_LOG}"

# Generate HTML coverage report
log_info "Generating HTML coverage report..."
genhtml coverage/lcov.info -o coverage/html --quiet

log_success "HTML coverage report generated at: coverage/html/index.html"

# Extract coverage percentage
COVERAGE_PERCENT=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')

log_info "Current code coverage: ${COVERAGE_PERCENT}%"

# Check coverage threshold
REQUIRED_COVERAGE=80
if (( $(echo "$COVERAGE_PERCENT < $REQUIRED_COVERAGE" | bc -l) )); then
    log_error "Coverage ${COVERAGE_PERCENT}% is below required ${REQUIRED_COVERAGE}%"
    
    # Show files with low coverage
    log_info "Files with low coverage:"
    lcov --list coverage/lcov.info | grep -E "^[[:space:]]*[0-9]+\.[0-9]+%" | sort -n | head -n 10 || true
    
    exit 1
else
    log_success "Coverage ${COVERAGE_PERCENT}% meets requirement (≥${REQUIRED_COVERAGE}%)"
fi

# List untested files
log_info "Checking for untested files..."
UNTESTED_LOG="${LOGS_DIR}/untested_files_${TIMESTAMP}.log"

# Get all dart files in lib/
ALL_DART_FILES=$(find lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gen.dart" | wc -l)

# Get covered files from lcov
COVERED_FILES=$(lcov --list coverage/lcov.info | grep -c "lib/" || true)

log_info "Total source files: ${ALL_DART_FILES}"
log_info "Files with tests: ${COVERED_FILES}"

if [ "$COVERED_FILES" -lt "$ALL_DART_FILES" ]; then
    log_warning "Some files may not have tests"
    
    # List files with 0% coverage
    lcov --list coverage/lcov.info | grep "0.0%" > "${UNTESTED_LOG}" || true
    
    if [ -s "${UNTESTED_LOG}" ]; then
        log_warning "Files with 0% coverage:"
        cat "${UNTESTED_LOG}"
    fi
fi

# Package analysis
log_section "10. Package Analysis (pub.dev score)"

log_info "Running package analysis..."
PANA_LOG="${LOGS_DIR}/pana_${TIMESTAMP}.log"

# Activate pana if not already
dart pub global activate pana > /dev/null 2>&1 || true

if dart pub global run pana --no-warning --json > "${PANA_LOG}" 2>&1; then
    log_success "Package analysis completed"
    
    # Extract scores
    if command -v jq &> /dev/null; then
        SCORE=$(jq -r '.scores.grantedPoints // 0' "${PANA_LOG}" 2>/dev/null || echo "0")
        MAX_SCORE=$(jq -r '.scores.maxPoints // 0' "${PANA_LOG}" 2>/dev/null || echo "0")
        log_info "Package score: ${SCORE}/${MAX_SCORE}"
    fi
else
    log_warning "Package analysis failed (non-blocking)"
fi

# Publish dry run
log_section "11. Publish Dry Run"

log_info "Testing package publishing..."
PUBLISH_LOG="${LOGS_DIR}/publish_dry_run_${TIMESTAMP}.log"

if dart pub publish --dry-run 2>&1 | tee "${PUBLISH_LOG}"; then
    log_success "Package can be published"
else
    log_error "Package has publishing issues"
    log_error "See details in: ${PUBLISH_LOG}"
    exit 1
fi

# Dependency check
log_section "12. Dependency Check"

log_info "Checking for outdated dependencies..."
DEP_LOG="${LOGS_DIR}/dependencies_${TIMESTAMP}.log"

flutter pub outdated --show-all --no-dev-dependencies 2>&1 | tee "${DEP_LOG}" || true

if grep -q "All dependencies are up to date" "${DEP_LOG}"; then
    log_success "All dependencies are up to date"
else
    log_warning "Some dependencies may need updates (non-blocking)"
fi

# Generate test summary
log_section "13. Test Summary"

log_info "Generating test summary..."

cat > "${LOGS_DIR}/summary_${TIMESTAMP}.txt" << EOF
═══════════════════════════════════════════════
Flutter AI Agent SDK - Test Summary
═══════════════════════════════════════════════

Test Run: ${TIMESTAMP}
Date: $(date)

✓ Environment Setup
✓ Code Formatting
✓ Static Analysis
✓ Tests Execution
✓ Coverage Analysis

Code Coverage: ${COVERAGE_PERCENT}%
Total Source Files: ${ALL_DART_FILES}
Files with Tests: ${COVERED_FILES}

Logs Generated:
- Main Log: ${LOG_FILE}
- Analysis: ${ANALYSIS_LOG}
- Tests: ${TEST_LOG}
- Coverage: ${COVERAGE_LOG}
- Package Analysis: ${PANA_LOG}
- Publish Check: ${PUBLISH_LOG}

HTML Coverage Report: coverage/html/index.html

═══════════════════════════════════════════════
EOF

cat "${LOGS_DIR}/summary_${TIMESTAMP}.txt"

log_section "✅ All Tests Passed!"

log_success "Test suite completed successfully!"
log_info "View detailed logs in: ${LOGS_DIR}/"
log_info "View coverage report: coverage/html/index.html"
log_info ""
log_info "Next steps:"
log_info "  1. Open coverage/html/index.html in a browser"
log_info "  2. Review logs in ${LOGS_DIR}/ for any warnings"
log_info "  3. Aim for 100% code coverage by adding missing tests"

exit 0
