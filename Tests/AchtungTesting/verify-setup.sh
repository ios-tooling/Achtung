#!/bin/bash

# AchtungTesting Setup Verification Script

echo "🔍 Verifying AchtungTesting Configuration..."
echo ""

# Check project file exists
if [ -f "AchtungTesting.xcodeproj/project.pbxproj" ]; then
    echo "✅ Project file found"
else
    echo "❌ Project file not found"
    exit 1
fi

# Check test files exist
echo ""
echo "📝 Checking test files..."
TEST_FILES=(
    "Tests/AchtungToastTests.swift"
    "Tests/AchtungAlertTests.swift"
    "Tests/AchtungErrorHandlingTests.swift"
    "Tests/AchtungErrorRecordingTests.swift"
    "Tests/AchtungIntegrationTests.swift"
    "Tests/AchtungDisplayStyleTests.swift"
    "Tests/AchtungUtilityTests.swift"
)

MISSING=0
for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (MISSING)"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo ""
    echo "✅ All 7 test files present"
else
    echo ""
    echo "❌ $MISSING test file(s) missing"
    exit 1
fi

# Check framework reference
echo ""
echo "🔗 Checking Achtung framework reference..."
if grep -q "Achtung" AchtungTesting.xcodeproj/project.pbxproj; then
    echo "✅ Achtung framework referenced in project"
else
    echo "❌ Achtung framework not found in project"
    exit 1
fi

# Check test target configuration
echo ""
echo "🎯 Checking test target..."
if grep -q "Tests.xctest" AchtungTesting.xcodeproj/project.pbxproj; then
    echo "✅ Test target configured"
else
    echo "❌ Test target not found"
    exit 1
fi

# Count total tests
echo ""
echo "📊 Test Statistics..."
TEST_COUNT=$(grep -r "func test" Tests/*.swift | wc -l | xargs)
echo "  📝 Approximate test count: $TEST_COUNT tests"
echo "  📁 Test files: 7"

# Check deployment targets
echo ""
echo "🎯 Deployment Targets..."
if grep -q "IPHONEOS_DEPLOYMENT_TARGET = 14.0" AchtungTesting.xcodeproj/project.pbxproj; then
    echo "  ✅ iOS deployment target: 14.0"
else
    echo "  ⚠️  iOS deployment target may need adjustment"
fi

if grep -q "MACOSX_DEPLOYMENT_TARGET = 11.0" AchtungTesting.xcodeproj/project.pbxproj; then
    echo "  ✅ macOS deployment target: 11.0"
else
    echo "  ⚠️  macOS deployment target may need adjustment"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Configuration Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Open project: open AchtungTesting.xcodeproj"
echo "  2. Build project: Cmd+B"
echo "  3. Run tests: Cmd+U"
echo ""
echo "Or run tests from command line:"
echo "  xcodebuild test -scheme AchtungTesting -destination 'name=iPhone 15 Pro'"
echo ""
