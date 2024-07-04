import random

TEST_PATH="./tests"

def randbyte():
    return random.randint(0, 255)

def append_rand_bytes(b, n):
    b.extend([randbyte() for _ in range(n)]) 

def to_32_bits_u2(x):
    assert -(2 ** 31) <= x < (2 ** 31)
    result = [0] * 4
    for i in range(4):
        result[i] = x & 0xff
        x >>= 8
    return result

def write_byte_array_to_a_file(byte_array, filename):
    with open(filename, 'wb') as file:
        file.write(bytes(byte_array))
        

random.seed(7)

arr1 = [134, 32] + [randbyte() for _ in range(2000)]

write_byte_array_to_a_file(arr1, "tests/plik3")

arr2 = [10, 0] + [randbyte() for _ in range(10)] + to_32_bits_u2(-30)

write_byte_array_to_a_file(arr2, "tests/plik4")
