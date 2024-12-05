.global _start

# .section .data
# #=====() =====() = =
# # = = = =
# # = = = = 
# # \t\t = \t\t = \t \t=
# #\t\t = \t \t\t\t = 
# #= = =
# command: .asciz "\t\t = \t \t\t\t = "
# result: .byte 0

.section .text
_start:

    # Initialize registers
    movq $command, %rsi        # Load address of input string into %rsi
    movb $0, result(%rip)      # Set result to 0 initially (invalid)
    movq %rsi, %rdi            # Copy %rsi to %rdi for parsing

    cmpb $0, (%rsi)            # Check if the string is empty
    je set_result_valid             # If empty, jump to end

    cmpb $61, (%rsi)            # Check if the string is =
    je check_after_equals             # If empty, jump to end

    # Begin parsing
    jmp check_cases12_new            # Start by checking Case 1

#--------------------------------------------
# Case 1: Declaration composed of 4 parts
#--------------------------------------------
check_cases12_new:
    mov $0, %rax               # Part counter
    jmp process_words_until_equals

process_words_until_equals:
    cmpb $0, (%rdi)            # Check if the string is empty
    je start_edge_case_count_blocks
    
    # set flag to 0
    movq $0, %r8
    cmpb $32, (%rdi)        # Space
    je skip_spaces_case12
    cmpb $9, (%rdi)         # Tab
    je skip_spaces_case12
    cmpb $61, (%rdi) # The word ended without a space, the "equeal" right after it
    je finished_proccessing_word
    cmpq $1, %r8 # The word ended with a space
    je finished_proccessing_word # Means that we encounter space or a group of spaces

    inc %rdi
    jmp process_words_until_equals
    finished_proccessing_word:
        inc %rax # The part counter

        cmpb $61, (%rdi)           # Check for '='
        je found_equals
        jmp process_words_until_equals

found_equals:
    cmpq $2, %rax # check counted parts
    jle check_after_equals # If found enough parts before the equals
    jmp start_edge_case_count_blocks

skip_spaces_case12:
    # Set flag to 1
    movq $1, %r8
    # Skip multiple spaces or tabs between parts
    skip_space_loop_case12:
        inc %rdi
        cmpb $32, (%rdi)
        je skip_space_loop_case12
        cmpb $9, (%rdi)
        je skip_space_loop_case12

        jmp finished_proccessing_word

check_after_equals:
    movq $0, %rax
    inc %rdi

    cmpb $0, (%rdi)            # Check if the string is empty
    je set_result_valid

    # movq $0, %r8
    cmpb $32, (%rdi)        # Space
    je skip_spaces_case12_after_equals
    cmpb $9, (%rdi)         # Tab
    je skip_spaces_case12_after_equals

    after_cleaning_spaces:
        # cmpq $1, %r8 # If there was spaces after the equals, all good.
        # je process_words_end
        jmp process_words_end


skip_spaces_case12_after_equals:
    # Set flag to 1
    movq $1, %r8
    # Skip multiple spaces or tabs between parts
    skip_space_loop_case12_after_equals:
        inc %rdi
        cmpb $32, (%rdi)
        je skip_space_loop_case12_after_equals
        cmpb $9, (%rdi)
        je skip_space_loop_case12_after_equals

        jmp after_cleaning_spaces

process_words_end:
    # set flag to 0
    cmpb $0, (%rdi)            # Check if the string is empty
    je set_result_valid
    movq $0, %r8
    cmpb $32, (%rdi)        # Space. If here we'll find any new space, it's not good.
    je start_edge_case_count_blocks
    cmpb $9, (%rdi)         # Tab. If here we'll find any new space, it's not good.
    je start_edge_case_count_blocks
    
    inc %rdi
    jmp process_words_end

start_edge_case_count_blocks:
    # Starts with a char.
    # Ends with a char.
    # The third block is only and only '='
    movq %rsi, %rdi            # get the original pointer
    movq $0, %rax              # Part counter

    #  if the first char is a space, count as rax=1
    cmpb $32, (%rdi)        # Space
    je skip_spaces_case22
    cmpb $9, (%rdi)         # Tab
    je skip_spaces_case22
    jmp process_blocks_until_end

    skip_spaces_case22:
        cmpb $32, (%rdi)
        je inc_rdi_case22
        cmpb $9, (%rdi)
        je inc_rdi_case22
        jmp process_blocks_until_end

        inc_rdi_case22:
            movq $1, %rax
            inc %rdi
            jmp skip_spaces_case22

    process_blocks_until_end:
        cmpb $0, (%rdi)            # Check if the string is empty
        je check_process_blocks_end
        
        # set flag to 0
        movq $0, %r8
        cmpb $32, (%rdi)        # Space
        je skip_spaces_for_counting_blocks
        cmpb $9, (%rdi)         # Tab
        je skip_spaces_for_counting_blocks
        
        # cmpq $1, %r8 # The word ended with a space
        # je finished_proccessing_word_2 # Means that we encounter space or a group of spaces
        movb (%rdi), %r9b # Will hold the last char of this block

        inc %rdi
        jmp process_blocks_until_end
        finished_proccessing_word_2:
            inc %rax # The part counter

            movb $0, %r9b
            #rax is the 3 blc, we need to check if it's '='
            cmpq $2, %rax # finished scanning 3 block, check if the last block is only a '='
            je check_third_equals_block

            jmp process_blocks_until_end

inc_the_block_count:
    inc %rax
    jmp process_blocks_until_end

check_third_equals_block:
    cmpb $61, (%rdi) # Check if the last char is '='
    jne check_case3

    addq $1, %rdi
    cmpb $32, (%rdi) # Space
    je inc_the_block_count
    cmpb $9, (%rdi) # Space
    je inc_the_block_count
    jmp check_case3

skip_spaces_for_counting_blocks:
    # Set flag to 1
    movq $1, %r8
    # Skip multiple spaces or tabs between parts
    skip_space_loop_for_counting_blocks:
        inc %rdi
        cmpb $32, (%rdi)
        je skip_space_loop_for_counting_blocks
        cmpb $9, (%rdi)
        je skip_space_loop_for_counting_blocks

        jmp finished_proccessing_word_2

check_if_was_chars_before_last_spaces:
    cmpb $0, %r9b
    jne check_case3 # was chars, next case
    jmp check_good_blocks


check_process_blocks_end:
    # TODO : Allow the last forth' block to be spaces. 
    cmpq $1, %r8 # The entire input string ended with a space. 
    je check_if_was_chars_before_last_spaces

check_good_blocks:
    cmpq $4, %rax # check counted parts # TODO: Can be made with 3
    je set_result_valid
    jmp check_case3 # If found enough



    # Until here, check how many blocked were there and if the 3'rd block is a '='



# check_what_found_after_equals:
    # we done running the string, check if we found chars/spaces

# check_case1:
#     movq %rdi, %rcx            # Save the original pointer
#     mov $0, %rax               # Part counter
#     jmp count_parts_case1

# count_parts_case1:
#     cmpb $0, (%rdi)            # Check for null terminator
#     je check_case2             # If end of string, check next case

#     cmpb $32, (%rdi)           # Check for space ' '
#     je skip_spaces_case1
#     cmpb $9, (%rdi)            # Check for tab '\t'
#     je skip_spaces_case1

#     # Start of a part
#     inc %rax                   # Increment part counter

# scan_part_case1:
#     cmpb $0, (%rdi)            # End of string?
#     je check_case1_result
#     cmpb $32, (%rdi)           # Space?
#     je count_parts_case1
#     cmpb $9, (%rdi)            # Tab?
#     je count_parts_case1

#     # Check for spaces or tabs within a part (not allowed)
#     # Advance pointer
#     inc %rdi
#     jmp scan_part_case1

# skip_spaces_case1:
#     # Skip multiple spaces or tabs between parts
# skip_space_loop_case1:
#     inc %rdi
#     cmpb $32, (%rdi)
#     je skip_space_loop_case1
#     cmpb $9, (%rdi)
#     je skip_space_loop_case1

#     jmp count_parts_case1

# check_case1_result:
#     cmp $4, %rax               # Check if exactly 4 parts
#     je set_result_valid        # If so, valid syntax
#     # Else, reset pointer and check next case
#     movq %rcx, %rdi
#     jmp check_case2

# #--------------------------------------------
# # Case 2: Simple assignment composed of 3 parts
# #--------------------------------------------
# check_case2:
#     movq %rdi, %rcx            # Save the original pointer
#     mov $0, %rax               # Part counter
#     jmp count_parts_case2

# count_parts_case2:
#     cmpb $0, (%rdi)            # Check for null terminator
#     je check_case3             # If end of string, check next case

#     cmpb $32, (%rdi)           # Check for space ' '
#     je skip_spaces_case2
#     cmpb $9, (%rdi)            # Check for tab '\t'
#     je skip_spaces_case2

#     # Start of a part
#     inc %rax                   # Increment part counter

# scan_part_case2:
#     cmpb $0, (%rdi)            # End of string?
#     je check_case2_result
#     cmpb $32, (%rdi)           # Space?
#     je count_parts_case2
#     cmpb $9, (%rdi)            # Tab?
#     je count_parts_case2

#     # Advance pointer
#     inc %rdi
#     jmp scan_part_case2

# skip_spaces_case2:
#     # Skip multiple spaces or tabs between parts
# skip_space_loop_case2:
#     inc %rdi
#     cmpb $32, (%rdi)
#     je skip_space_loop_case2
#     cmpb $9, (%rdi)
#     je skip_space_loop_case2

#     jmp count_parts_case2

# check_case2_result:
#     cmp $3, %rax               # Check if exactly 3 parts
#     je set_result_valid        # If so, valid syntax
#     # Else, reset pointer and check next case
#     movq %rcx, %rdi
#     jmp check_case3

#--------------------------------------------
# Case 3: Function-like declaration
#--------------------------------------------
check_case3:
    movq %rsi, %rdi            # get the original pointer

    # Skip leading spaces and tabs before function name
    # TODO: If found spaces as the first char then the name is empty
    movb $0, %r8b
    skip_spaces_case3:
        cmpb $32, (%rdi)
        je inc_rdi_case3
        cmpb $9, (%rdi)
        je inc_rdi_case3
        jmp function_name_case3

    inc_rdi_case3:
        movb $1, %r8b # flag - the string started with spaces
        inc %rdi
        jmp skip_spaces_case3

    function_name_case3:
        cmpb $0, (%rdi)        # End of string?
        je check_case4         # No function name, check next case
        cmpb $40, (%rdi)       # Check for '(' ASCII code 40
        je after_paren_case3   # Found '(', proceed

        # Scan function name (any non-space, non-tab, non-null, non-'(')
        cmpb $32, (%rdi)       # Space?
        je skip_spaces_case_until_open         # Invalid, check next case
        cmpb $9, (%rdi)        # Tab?
        je skip_spaces_case_until_open         # Invalid, check next case
        cmpb $40, (%rdi)       # '('?
        je after_paren_case3   # Found '(', proceed

        cmpb $1, %r8b
        je check_case4 # we found space and char before the first (

        inc %rdi
        jmp function_name_case3

    skip_spaces_case_until_open:
        cmpb $32, (%rdi)
        je inc_rdi_case3_until_open
        cmpb $9, (%rdi)
        je inc_rdi_case3_until_open

        # check if '('
        cmpb $40, (%rdi)       # '('?
        je after_paren_case3   # Found '(', proceed
        jmp check_case4

    inc_rdi_case3_until_open:
        inc %rdi
        jmp skip_spaces_case3

    after_paren_case3:
        # Skip any spaces or tabs between function name and '('
        # skip_spaces_before_paren_case3:
        #     cmpb $32, -1(%rdi)   # Check previous character for space
        #     jne check_paren_case3
        #     dec %rdi
        #     jmp skip_spaces_before_paren_case3

        # check_paren_case3:
        #     inc %rdi            # Move back to '('
        #     cmpb $40, (%rdi)    # Ensure current char is '('
        #     jne check_case4     # Not '(', invalid, check next case

        # # Now, check for matching ')'
        # inc %rdi                # Skip '('
        # mov %rdi, %rbx          # Save pointer to content inside parentheses

        find_closing_paren_case3:
            cmpb $0, (%rdi)     # End of string?
            je check_if_closed_properly
            # je check_case4      # No closing ')', invalid
            # cmpb $41, (%rdi)    # Check for ')', ASCII code 41
            # je after_closing_paren_case3
            movb (%rdi), %r11b # Save the last char
            inc %rdi
            jmp find_closing_paren_case3

            check_if_closed_properly:
                cmpb $41 ,%r11b
                je set_result_valid
                jmp check_case4

    after_closing_paren_case3:
        inc %rdi                # Move past ')'

        # Skip any trailing spaces or tabs
        skip_trailing_spaces_case3:
            cmpb $32, (%rdi)
            je inc_rdi_trailing_case3
            cmpb $9, (%rdi)
            je inc_rdi_trailing_case3
            cmpb $0, (%rdi)
            je set_result_valid # End of string, valid syntax
            jmp check_case4     # Invalid characters after ')'

        inc_rdi_trailing_case3:
            inc %rdi
            jmp skip_trailing_spaces_case3


#--------------------------------------------
# Case 4: Single word
#--------------------------------------------
check_case4:
    movq %rsi, %rdi            # Reset pointer to start

    cmpb $0, (%rdi)            # Check if string is empty
    je end_program             # Empty string, already result = 0

    # Check for spaces or tabs in the string
check_single_word:
    cmpb $0, (%rdi)        # End of string?
    je set_result_valid    # No spaces or tabs found, valid single word
    cmpb $32, (%rdi)       # Space?
    je end_program         # Invalid, contains space
    cmpb $9, (%rdi)        # Tab?
    je end_program         # Invalid, contains tab
    inc %rdi
    jmp check_single_word


#--------------------------------------------
# Set result to valid (1) and exit
#--------------------------------------------
set_result_valid:
    movb $1, result(%rip)      # Set result to 1 (valid)
    jmp end_program

#--------------------------------------------
# End of program
#--------------------------------------------
end_program:

    # movq $60, %rax
    # xorq %rdi, %rdi
    # syscall

/*
as ex5.asm -o ex5.o && ld ex5.o -o ex5 && ./ex5

*/