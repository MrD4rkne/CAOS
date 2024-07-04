#!/bin/python3

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

class Section:
    def __init__(this, position, length):
        assert 0 <= length < (2 ** 16)
        assert position >= 0
        this.length = length + 6    # Total length, including two bytes at
                                    # the front and four bytes at the end.
        this.position = position

    def write(this, byte_array, next_section_position):
        assert len(byte_array) >= this.position + this.length
        # Write the length of the section into the first two bytes.
        byte_array[this.position + 0] = (this.length - 6) & 0xff
        byte_array[this.position + 1] = (this.length - 6) >> 8

        # Write random bytes as the content of the section.
        for i in range(this.length - 6):
            byte_array[this.position + 2 + i] = randbyte()

        # Calculate the offset needed to go to the next section.
        offset = next_section_position - (this.position + this.length)
        
        # Write the bytes of offset into the byte_array.
        offset_bytes = to_32_bits_u2(offset)
        for i in range(4):
            byte_array[this.position + this.length - 4 + i] = offset_bytes[i]
        
    

def create_byte_array_from_sections(sections, length):
    byte_array = [randbyte() for _ in range(length)]

    for i in range(len(sections)):
        # j is the position of the next section.
        j = i + 1 if i < len(sections) - 1 else i
        sections[i].write(byte_array, sections[j].position)
    
    return byte_array
    

def generate_serial_test(num_sections, s_length, g_length, o_length):
    assert num_sections >= 1 and 0 <= s_length <= g_length

    # Sections go one after another (1 - 2 - 3 - ... - n)
    # with spaces in between.

    last_position = 0
    sections = []
    for _ in range(num_sections): 
        length = random.randint(s_length, g_length)
        sections.append(Section(last_position, length))
        last_position += length + 6 + random.randint(0, o_length)

    return sections, last_position
    
    
def generate_zigzag_test(num_sections, s_length, g_length, o_length):
    assert num_sections >= 1 and 0 <= s_length <= g_length

    # Sections go in a zigzag pattern (1 - 3 - 2 - 4 - 6 - 5 - ...).
    
    serial_sections, last_position = generate_serial_test(num_sections, s_length, 
                                                                        g_length, 
                                                                        o_length)

    zigzag_sections = []
    for i in range(num_sections - num_sections % 3):
        if i % 3 == 0:
            zigzag_sections.append(serial_sections[i])
        if i % 3 == 1:
            zigzag_sections.append(serial_sections[i + 1])
        if i % 3 == 2:
            zigzag_sections.append(serial_sections[i - 1])

    for i in range(num_sections - num_sections % 3, num_sections):
        zigzag_sections.append(serial_sections[i])

    return zigzag_sections, last_position
    

def generate_jumping_test(num_sections, s_length, g_length, o_length):
    assert num_sections >= 1 and 0 <= s_length <= g_length
    
    serial_sections, last_position = generate_serial_test(num_sections, s_length, 
                                                                        g_length, 
                                                                        o_length)
 
    jumping_sections = []
    for i in range(num_sections // 2):
        jumping_sections.append(serial_sections[i])
        jumping_sections.append(serial_sections[num_sections // 2 + i])
    
    if num_sections % 2 == 1:
        jumping_sections.append(serial_sections[-1])
    
    return jumping_sections, last_position

def write_byte_array_to_a_file(byte_array, filename):
    with open(filename, 'wb') as file:
        file.write(bytes(byte_array))
        

random.seed(7)

MAX_LEN = 2 ** 16 - 1

params = [ [3, 3, 8, 8],
           [20, 128, 255, 16],
           [1000, 2, 16, 2],
           [10000, 0, 2, 2],
           [10, MAX_LEN, MAX_LEN, 16],
           [100, MAX_LEN, MAX_LEN, 16],
           [100, 50, 150, 8],
           [500, 10, 30, 8],
           [50, 100, 255, 8],
           [20, 0, MAX_LEN, 2 ** 17], 
         ]

tests = []

one_section_tests = [  
                        (generate_serial_test, [1,       5,       5, 3]), # Small.
                        (generate_serial_test, [1,     255,     255, 3]), # Medium.
                        (generate_serial_test, [1, MAX_LEN, MAX_LEN, 3]), # Large.
                     ]

tests.extend(one_section_tests)

test_kinds = [ generate_serial_test,
               generate_zigzag_test,
               generate_jumping_test,
             ]

for test_gen in test_kinds:
    tests.extend([(test_gen, p) for p in params])

for test_id, (gen_test, args) in enumerate(tests):
    print("Generating test ", test_id, "...", sep="")
    sections, length = gen_test(args[0], args[1], args[2], args[3])
    byte_array = create_byte_array_from_sections(sections, length)
    write_byte_array_to_a_file(byte_array, 
                               TEST_PATH + "/test" + str(test_id) + ".in")
    print("Test ", test_id, " generated.", sep="")
