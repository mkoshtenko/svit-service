#!/bin/sh

DESTINATION_DIR=$1

if [[ -z "${DESTINATION_DIR}" ]]; then
    echo "Invalid argument: Destination for exported data was not specified."
    exit 22
else
    echo "Destination: ${DESTINATION_DIR}"
    mkdir -p "${DESTINATION_DIR}"
fi

BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find ${BIN_PATH} -name '*.xctest')"

# if it's running on Mac OSX we use `xcrun` to get access to llvm tools
# the file path is also different
LLVM_COV='llvm-cov'
COV_BIN=$XCTEST_PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    f="$(basename $XCTEST_PATH .xctest)"
    COV_BIN="${COV_BIN}/Contents/MacOS/$f"
    LLVM_COV='xcrun llvm-cov'
fi

PROFILE_PATH=".build/debug/codecov"

# export codecoverage data from binary.
# by default it includes coverage data for all the dependencies and tests,
# therefore we should use filtering `-ignore-filename-regex`
$LLVM_COV export "${COV_BIN}" \
  -instr-profile="${PROFILE_PATH}"/default.profdata \
  -format lcov >> app.coverage.lcov \
  -ignore-filename-regex="\.build/.*|Tests/.*"

cp -r "${PROFILE_PATH}"/* ${DESTINATION_DIR}
