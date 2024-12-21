#!/bin/bash
gcc test1.c aux_hw3.o students_code.S -o hw3_part1.out
if [ -f "hw3_part1.out" ]; then
	timeout 20s ./hw3_part1.out > out
	diff out out1
	if [ $? -eq 0 ]; then
		echo -e "\n\nTest:\tPASS"
	else
		echo -e "\n\nTest:\tFAIL - diff"
	fi
	rm out
else
	echo -e "Test:\tFAIL - compile with test error"
fi
rm hw3_part1.out
echo "END OF TEST"
