# Long (really long) number division

Implementation of the mdiv function in assembly, callable from C, which performs integer division with remainder.
Function divides 64*n bits number by 64 bit number, both in two's complement.

## Original task
[Original task in Polish](./task.pdf)

## Implementation

The mdiv function is implemented in assembly language and handles overflow conditions (including division by zero). In case of overflow, the function raises an interrupt similar to the div and idiv instructions on processors, which in Linux results in sending a `SIGFPE` signal to the process.

## Compilation

An example of using the mdiv function is provided in the mdiv_example.c file. To compile the example, use the following commands:
```bash
gcc -c -Wall -Wextra -std=c17 -O2 -o mdiv_example.o mdiv_example.c
gcc -z noexecstack -o mdiv_example mdiv_example.o mdiv.o
```

## How to call it

```c
int64_t mdiv(int64_t *x, size_t n, int64_t y);
```
- `x`: Pointer to a non-empty array of 64-bit integers representing the dividend in little-endian format.
- `n`: Number of elements in the array x.
- `y`: Divisor.

The function performs integer division of x by y, stores the quotient (result) in the array x, and returns the remainder.

## Tests
To run tests call:
```bash
bash test,sh
```