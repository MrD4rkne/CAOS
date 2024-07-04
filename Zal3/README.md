# CRC Calculator

This program, written in NASM, calculates the CRC remainder using a given polynomial. It uses look-up table to speed up the process.

## Usage

### 1. Compile the Program

To compile the program, run:
```bash
make crc
```

### 2. Run te program

To execute the CRC calculator, use the following command:
```bash
crc file_path polynomial
```

- polynomial: A 64-bit number consisting only of 0s and 1s. There is an additional most significant 65th bit which is set to 1.
- file_path: Path to file. Additionally the file should consist of segments structured as follows:
  - [2 bytes for length in natural binary]
  - [data]
  - [4 bytes for jump in U2]
The beggining of the file should be the first segment. The end of the file is marked by a jump pointing at the current segment.

Example:
> hexdump plik1
```
00 02 ee 34 ff f8 ff ff
```
- Length: 2
- Data: 34 ee
- Jump: ff ff ff f8 (decimal: -8)

#### Notes
- Program does not detect cycles.
- On success, the program returns 0 and prints the CRC remainder.
- On any error (invalid input, system call errors), the program returns 1.

### 3. Testing
To launch the tests given in task, run:
```bash
bash ./tesh.sh
```
*Note: File2 was too large to attach*

### 4. Task:
[Original task in Polish](./task.pdf)
