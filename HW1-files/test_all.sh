#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Initialize status
STATUS=0

# Loop through assembly files ex1.asm to ex5.asm and their corresponding test directories
for NUM in {1..5}; do
    ASM_FILE="$SCRIPT_DIR/ex${NUM}.asm"
    TEST_DIR="$SCRIPT_DIR/tests${NUM}"

    # Check if the assembly file exists
    if [ ! -f "$ASM_FILE" ]; then
        echo "Error: Assembly file '$ASM_FILE' does not exist. Skipping."
        continue
    fi

    # Check if the test directory exists
    if [ ! -d "$TEST_DIR" ]; then
        echo "Error: Test directory '$TEST_DIR' does not exist. Skipping."
        continue
    fi

    # Process each test file in the current test directory
    for TEST in "$TEST_DIR"/*; do
        TEST_NAME=$(basename -- "${TEST}")
        
        # Assemble and link
        as "$ASM_FILE" "$TEST" -o merged.o
        if [ -f "merged.o" ]; then
            ld merged.o -o merged.out
            if [ -f "merged.out" ]; then
                # Execute the binary with a timeout
                timeout 60s ./merged.out
                if [ $? -eq 0 ]; then
                    echo "${ASM_FILE} tested with ${TEST_NAME}: PASS"
                else
                    echo "${ASM_FILE} tested with ${TEST_NAME}: FAIL"
                    STATUS=1
                fi
            else
                echo "${ASM_FILE} could not be created (ld stage) with ${TEST_NAME}: FAIL"
                STATUS=1
            fi
        else
            echo "${ASM_FILE} could not be created (as stage) with ${TEST_NAME}: FAIL"
            STATUS=1
        fi

        # Cleanup for the current test
        rm -f merged.*
    done
done

# Exit with the overall status
exit ${STATUS}