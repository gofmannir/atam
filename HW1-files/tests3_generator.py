from random import randint, shuffle

first = """.global _start

.section .text

  movq root, %rdi
  xor %r8, %r8
  movl __ExpectedArraySize, %r8d
  movq $__ExpectedArray, %r9
  movq $0, %r10
  call rec

  cmp %r10, %r8
  jne bad_exit
  
  movq $60, %rax
  movq $0, %rdi
  syscall

bad_exit:
  movq $60, %rax
  movq $1, %rdi
  syscall

rec:
  pushq %rdi
  movq (%rdi), %r11
  cmp $0, %r11
  je skip_left
  movq %r11, %rdi
  call rec
  movq (%rsp), %rdi
skip_left:
  cmpq %r8, %r10
  je bad_exit
  movl 8(%rdi), %eax
  movl (%r9, %r10, 4), %edx
  cmpl %eax, %edx
  jne bad_exit
  inc %r10

  movq 12(%rdi), %r11
  cmp $0, %r11
  je skip_right
  movq %r11, %rdi
  call rec
skip_right:
  popq %rdi
  ret


.section .data
"""

def generate_garbage():
	length = randint(0, 10)
	if length == 0:
		return ""
	result = "__Garbage_" + str(randint(0, 1000000000)) + ": .byte "
	data = []
	for i in range(length):
		data.append(str(randint(0, 255)))
	result += ", ".join(data)
	return result

def generate_test(length, is_same, test_number):
	result = first

	data_set = set()

	while len(data_set) < length:
		data_set.add(randint(-2147483648, 2147483648))

	data = sorted(list(data_set))
	nodes = []

	def rec(l, r):
		if l > r:
			return -1
		here = randint(l, r)
		arr = [-1, data[here], -1]
		arr[0] = rec(l, here - 1)
		arr[2] = rec(here + 1, r)
		nodes.append(arr)
		return len(nodes) - 1

	rec(0, length - 1)

	node_value = 0
	if is_same:
		node_value = data[randint(0, length - 1)]
	else:
		node_value = randint(-2147483648, 2147483648)
		while node_value in data_set:
			node_value = randint(-2147483648, 2147483648)

	data_set.add(node_value)

	expected_array = sorted(list(data_set))

	result += "__ExpectedArray: .int "
	result += ", ".join(map(str, expected_array)) + "\n"

	result += generate_garbage() + "\n"

	result += "__ExpectedArraySize: .int " + str(len(expected_array)) + "\n"

	result += generate_garbage() + "\n"

	result += "__Nodes:\n"

	renum = []
	for i in range(length):
		renum.append(i)

	shuffle(renum)

	rev = [0] * length

	for i in range(length):
		rev[renum[i]] = i


	for i in range(length):
		if nodes[renum[i]][0] != -1:
			result += ".quad __Nodes + " + str(rev[nodes[renum[i]][0]] * 20) + "\n"
		else:
				result += ".quad 0\n"
		result += ".int " + str(nodes[renum[i]][1]) + "\n"
		if nodes[renum[i]][2] != -1:
			result += ".quad __Nodes + " + str(rev[nodes[renum[i]][2]] * 20) + "\n"
		else:
			result += ".quad 0\n"


	result += generate_garbage() + "\n"

	result += "root:\n"
	result += ".quad __Nodes + " + str(rev[length - 1] * 20) + "\n"

	result += generate_garbage() + "\n"

	garbage1 = randint(-2147483648, 2147483648)
	garbage2 = randint(-2147483648, 2147483648)

	result += "node:\n"
	result += ".quad " + str(garbage1) + "\n"
	result += ".int " + str(node_value) + "\n"
	result += ".quad " + str(garbage2) + "\n"

	
	with open("tests3/test" + str(test_number), "w") as f:
		f.write(result)


generate_test(1, 1, 1)
generate_test(1, 0, 2)
generate_test(2, 1, 3)
generate_test(2, 0, 4)
for test_number in range(5, 21):
	length = randint(1, 10)
	is_same = False
	if randint(1, 3) == 1:
		is_same = True
	generate_test(length, is_same, test_number)
for test_number in range(21, 51):
	length = randint(1, 100)
	is_same = False
	if randint(1, 3) == 1:
		is_same = True
	generate_test(length, is_same, test_number)
for test_number in range(51, 101):
	length = randint(1, 10000)
	is_same = False
	if randint(1, 3) == 1:
		is_same = True
	generate_test(length, is_same, test_number)

	




