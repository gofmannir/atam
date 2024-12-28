#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int get_element_from_matrix(int* matrix, unsigned long max_col, unsigned long row, unsigned long col);
int inner_prod(int* mat_a, int* mat_b, unsigned long row_a, unsigned long col_b, unsigned long n, unsigned long q);
int matrix_multiplication(int* res, int* mat_a, int* mat_b, unsigned long m, unsigned long n, unsigned long o, unsigned long q, unsigned long p);


int get_element_from_matrix_solution(int* matrix, unsigned long max_col, unsigned long row, unsigned long col) {
	return matrix[row * max_col + col];
}

__int128 inner_prod_solution(int* mat_a, int* mat_b, unsigned long row_a, unsigned long col_b, unsigned long n, unsigned long q) {
	__int128 res = 0;
	row_a *= n;
	unsigned int curr_b = col_b;
	for (int i = 0; i < n; ++i) {
		res += (long long)mat_a[row_a + i] * (long long)mat_b[curr_b];
		curr_b += q;
	}
	return res;
}

int matrix_multiplication_solution(int* res, int* mat_a, int* mat_b, unsigned long m, unsigned long n, unsigned long o, unsigned long q, unsigned long p) {
	if (n != o) {
		return 0;
	}
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < q; j++) {
			int val = inner_prod_solution(mat_a, mat_b, i, j, n, q);
			val %= (int)p;
			if (val < 0) {
				val += p;
			}
			res[i * q + j] = val;
		}
	}
	return 1;
}

int INT_MIN = -2147483648;
int INT_MAX = 2147483647;

int matrix_multiplication_ok(int* res, int* mat_a, int* mat_b, unsigned long m, unsigned long n, unsigned long o, unsigned long q, unsigned long p) {
	if (n != o) {
		return 1;
	}
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < q; j++) {
			__int128 val = inner_prod_solution(mat_a, mat_b, i, j, n, q);
			if (val < INT_MIN || val > INT_MAX) {
				return 0;
			}
		}
	}
	return 1;
}

int a[1000000];
int b[1000000];
int c[1000000];
int d[1000000];

int get_random(int l, int r) {
	unsigned int len = (unsigned int)r - (unsigned int)l + 1;
	if (len == 0) {
		len = (unsigned int)-1;
	}
	unsigned int gen = ((unsigned int)rand() << 16) + (unsigned int)rand();
	gen %= len;
	return l + gen;
}

void gen_range(int* start, int size, int l, int r) {
	for (int i = 0; i < size; i++) {
		start[i] = get_random(l, r);
	}
}



int test_get_element_from_matrix_inner(int n1, int n2, int m1, int m2, int times) {
	for (int i = 0; i < times; i++) {
		int n = get_random(n1, n2);
		int m = get_random(m1, m2);
		int x = get_random(0, n - 1);
		int y = get_random(0, m - 1);
		int out = get_element_from_matrix(a, m, x, y);
		int expected = get_element_from_matrix_solution(a, m, x, y);
		if (out != expected) {
			return 1;
		}
	}
	return 0;
}

int test_get_element_from_matrix() {
	gen_range(a, sizeof(a) / sizeof(int), INT_MIN, INT_MAX);
	if (test_get_element_from_matrix_inner(1, 1, 1, 10, 1000)) return 1;
	if (test_get_element_from_matrix_inner(1, 1, 1, 1000000, 1000)) return 1;
	if (test_get_element_from_matrix_inner(1, 10, 1, 10, 1000)) return 1;
	if (test_get_element_from_matrix_inner(1, 1000, 1, 1000, 10000)) return 1;
	return 0;
}

int test_inner_prod_inner(int n1, int n2, int m1, int m2, int q1, int q2, int times) {
	for (int i = 0; i < times; i++) {
		int n = get_random(n1, n2);
		int m = get_random(m1, m2);
		int q = get_random(q1, q2);
		int x = get_random(0, n - 1);
		int y = get_random(0, q - 1);
		__int128 expected = inner_prod_solution(a, b, x, y, m, q);
		if (expected < INT_MIN || expected > INT_MAX) {
			continue;
		}
		int out = inner_prod(a, b, x, y, m, q);
		if (out != expected) {
			return 1;
		}
	}
	return 0;
}

int test_inner_prod() {
	gen_range(a, sizeof(a) / sizeof(int), -100, 100);
	gen_range(b, sizeof(b) / sizeof(int), -100, 100);
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 1000, 1, 1000, 1, 1000, 100)) return 1;
	gen_range(a, sizeof(a) / sizeof(int), -1000, 1000);
	gen_range(b, sizeof(b) / sizeof(int), -1000, 1000);
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 1000, 1, 1000, 1, 1000, 100)) return 1;
	gen_range(a, sizeof(a) / sizeof(int), -10000, 10000);
	gen_range(b, sizeof(b) / sizeof(int), -10000, 10000);
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_inner_prod_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_inner_prod_inner(1, 100, 1, 100, 1, 100, 100)) return 1;
	return 0;
}

int test_matrix_multiplication_inner(int n1, int n2, int m1, int m2, int q1, int q2, int times) {
	for (int i = 0; i < times; i++) {
		int n = get_random(n1, n2);
		int m = get_random(m1, m2);
		int q = get_random(q1, q2);
		int p = get_random(1, INT_MAX);

		if (!matrix_multiplication_ok(c, a, b, n, m, m, q, p)) {
			continue;
		}

		int ret = matrix_multiplication(c, a, b, n, m, m, q, p);
		if (ret != 1) {
			// printf("%d\n", ret);
			// printf("%d %d %d %d %d %d %d %d\n", n, m, q, a[0], b[0], c[0], d[0], p);
			return 1;
		}

		matrix_multiplication_solution(d, a, b, n, m, m, q, p);
		if (memcmp(c, d, 4 * n * q) != 0) {
			printf("%d %d %d %d %d %d %d %d\n", n, m, q, a[0], b[0], c[0], d[0], p);

			fflush(stdout);
			return 1;
		}
	}
	return 0;
}

int test_matrix_multiplication() {
	gen_range(a, sizeof(a) / sizeof(int), -100, 100);
	gen_range(b, sizeof(b) / sizeof(int), -100, 100);
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 200, 1, 200, 1, 200, 10)) return 1;
	gen_range(a, sizeof(a) / sizeof(int), -1000, 1000);
	gen_range(b, sizeof(b) / sizeof(int), -1000, 1000);
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 200, 1, 200, 1, 200, 10)) return 1;
	gen_range(a, sizeof(a) / sizeof(int), -10000, 10000);
	gen_range(b, sizeof(b) / sizeof(int), -10000, 10000);
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 10, 1, 1, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 1, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 1, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 10, 1, 10, 1, 10, 100)) return 1;
	if (test_matrix_multiplication_inner(1, 200, 1, 200, 1, 200, 10)) return 1;
	return 0;
}

int main() {
	srand(42);
	if (test_get_element_from_matrix()) {
		printf("get_element_from_matrix FAILED\n");
		return 0;
	}
	if (test_inner_prod()) {
		printf("inner_prod FAILED\n");
		return 0;
	}
	if (test_matrix_multiplication()) {
		printf("matrix_multiplication FAILED\n");
		return 0;
	}
	printf("OK\n");

	return 0;
}