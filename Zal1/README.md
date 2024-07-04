# NAND Gates
This project is a dynamically loadable C library for managing combinational Boolean circuits composed of NAND gates.

## Overview

- A NAND gate has a non-negative number of inputs and one output.
- A NAND gate with no inputs always outputs `false`.
- A NAND gate with one input acts as a negation.
- For a gate with `n` inputs, they are numbered from 0 to `n-1`.
- A Boolean signal (`false` or `true`) can be applied to the inputs.
- The output is `false` if all inputs are `true`; otherwise, the output is `true`.
- The output signal can be connected to multiple gate inputs, but each gate input can be connected to only one signal source.

## Original task
[Original task in Polish](./task.pdf)

## Library Interface

The library interface is defined in the provided `nand.h` file. For more details, refer to the example implementation in [`./tests/moodle/nand_example.c`](./tests/moodle/nand_example.c).

### Types and Functions

#### Type Definition

```c
typedef struct nand nand_t;
```
#### Create a NAND gate
```c
nand_t *nand_new(unsigned n);
```
- Creates a new NAND gate with n inputs.
- Returns a pointer to the NAND gate structure or `NULL` if memory allocation fails (errno set to `ENOMEM`).

#### Delete a NAND gate
```c
void nand_delete(nand_t *g);
```
- Disconnects all signals and frees memory for the specified gate.
- Does nothing if g is `NULL`.

#### Connect NAND Gates
```c
int nand_connect_nand(nand_t *g_out, nand_t *g_in, unsigned k);
```
- Connects the output of g_out to input k of g_in, replacing any existing connection.
- Returns `0` on success or `-1` on error (errno set to `EINVAL` or `ENOMEM`).

#### Connect Boolean Signal to Gate
```c
int nand_connect_signal(bool const *s, nand_t *g, unsigned k);
```
- Connects a Boolean signal s to input k of gate g.
- Returns `0` on success or `-1` on error (errno set to `EINVAL` or `ENOMEM`).

#### Evaluate Gates
```c
ssize_t nand_evaluate(nand_t **g, bool *s, size_t m);
```
- Computes the output values and critical path length for the specified gates.
- Returns the critical path length or `-1` on error (errno set to `EINVAL`, `ECANCELED` - on cycle, or `ENOMEM`).

#### Get output connections count
```c
ssize_t nand_fan_out(nand_t const *g);
```
- Returns the number of gate inputs connected to the output of gate g.
- Returns -1 on error (errno set to EINVAL).

#### Get signal from specified socket
```c
void* nand_input(nand_t const *g, unsigned k);
```
- Returns a pointer to the signal or gate connected to input k of gate g, or NULL if no connection.
- Returns NULL on error (errno set to EINVAL).

#### Get all output connections
```c
nand_t* nand_output(nand_t const *g, ssize_t k);
```
- Iterates over gates connected to the output of gate g.
- Returns a pointer to the connected gate.

## Additional Information
Refer to the nand_example.c file for detailed usage examples and further specifications.


## Testing
I've attached tests from task's author and my own. To launch all of them:
```bash
cd tests
bash test_all.sh