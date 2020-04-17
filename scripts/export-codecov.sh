#!/bin/sh

# export codecoverage data from binary.
# by default it includes coverage data for all the dependencies and tests,
# therefore we should use filtering `-ignore-filename-regex`
BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find ${BIN_PATH} -name '*.xctest')"

LLVM_COV='llvm-cov'
COV_BIN=$XCTEST_PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    f="$(basename $XCTEST_PATH .xctest)"
    COV_BIN="${COV_BIN}/Contents/MacOS/$f"
    LLVM_COV='xcrun llvm-cov'
fi

$LLVM_COV export "${COV_BIN}" \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format lcov >> app.coverage.lcov \
  -ignore-filename-regex="\.build/.*|Tests/.*"
