#!/bin/sh

# export codecoverage data from binary.
# by default it includes coverage data for all the dependencies and tests,
# therefore we should use filtering `-ignore-filename-regex`
xcrun llvm-cov export .build/debug/appPackageTests.xctest/Contents/MacOs/appPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format lcov >> app.coverage.lcov \
  -ignore-filename-regex="\.build/.*|Tests/.*"

