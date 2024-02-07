from math import bitcast
from math import rotate_bits_left


alias cpad = "=".data().bitcast[DType.uint8]()[0]
alias e0 = "AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLMMMMNNNNOOOOPPPPQQQQRRRRSSSSTTTTUUUUVVVVWWWWXXXXYYYYZZZZ"
            "aaaabbbbccccddddeeeeffffgggghhhhiiiijjjjkkkkllllmmmmnnnnooooppppqqqqrrrrssssttttuuuuvvvvwwwwxxxxyyyyzzzz"
            "0000111122223333444455556666777788889999++++////".data().bitcast[DType.uint8]()
alias e1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".data().bitcast[DType.uint8]()
alias BADCHAR = UInt32(0x01FFFFFF)

alias d0 = compute_d0()

fn compute_d0() -> DTypePointer[DType.uint32]:
    let d = SIMD[DType.uint32, 256](
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x000000f8, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x000000fc,
        0x000000d0, 0x000000d4, 0x000000d8, 0x000000dc, 0x000000e0, 0x000000e4,
        0x000000e8, 0x000000ec, 0x000000f0, 0x000000f4, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x00000000,
        0x00000004, 0x00000008, 0x0000000c, 0x00000010, 0x00000014, 0x00000018,
        0x0000001c, 0x00000020, 0x00000024, 0x00000028, 0x0000002c, 0x00000030,
        0x00000034, 0x00000038, 0x0000003c, 0x00000040, 0x00000044, 0x00000048,
        0x0000004c, 0x00000050, 0x00000054, 0x00000058, 0x0000005c, 0x00000060,
        0x00000064, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x00000068, 0x0000006c, 0x00000070, 0x00000074, 0x00000078,
        0x0000007c, 0x00000080, 0x00000084, 0x00000088, 0x0000008c, 0x00000090,
        0x00000094, 0x00000098, 0x0000009c, 0x000000a0, 0x000000a4, 0x000000a8,
        0x000000ac, 0x000000b0, 0x000000b4, 0x000000b8, 0x000000bc, 0x000000c0,
        0x000000c4, 0x000000c8, 0x000000cc, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff
    )
    let p = DTypePointer[DType.uint32].alloc(256)
    p.simd_store(d)
    return p
alias d1 = compute_d1()

fn compute_d1() -> DTypePointer[DType.uint32]:
    let d = SIMD[DType.uint32, 256](
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x0000e003, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x0000f003,
        0x00004003, 0x00005003, 0x00006003, 0x00007003, 0x00008003, 0x00009003,
        0x0000a003, 0x0000b003, 0x0000c003, 0x0000d003, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x00000000,
        0x00001000, 0x00002000, 0x00003000, 0x00004000, 0x00005000, 0x00006000,
        0x00007000, 0x00008000, 0x00009000, 0x0000a000, 0x0000b000, 0x0000c000,
        0x0000d000, 0x0000e000, 0x0000f000, 0x00000001, 0x00001001, 0x00002001,
        0x00003001, 0x00004001, 0x00005001, 0x00006001, 0x00007001, 0x00008001,
        0x00009001, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x0000a001, 0x0000b001, 0x0000c001, 0x0000d001, 0x0000e001,
        0x0000f001, 0x00000002, 0x00001002, 0x00002002, 0x00003002, 0x00004002,
        0x00005002, 0x00006002, 0x00007002, 0x00008002, 0x00009002, 0x0000a002,
        0x0000b002, 0x0000c002, 0x0000d002, 0x0000e002, 0x0000f002, 0x00000003,
        0x00001003, 0x00002003, 0x00003003, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff
    )
    let p = DTypePointer[DType.uint32].alloc(256)
    p.simd_store(d)
    return p

alias d2 = compute_d2()

fn compute_d2() -> DTypePointer[DType.uint32]:
    let d = SIMD[DType.uint32, 256](
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x00800f00, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x00c00f00,
        0x00000d00, 0x00400d00, 0x00800d00, 0x00c00d00, 0x00000e00, 0x00400e00,
        0x00800e00, 0x00c00e00, 0x00000f00, 0x00400f00, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x00000000,
        0x00400000, 0x00800000, 0x00c00000, 0x00000100, 0x00400100, 0x00800100,
        0x00c00100, 0x00000200, 0x00400200, 0x00800200, 0x00c00200, 0x00000300,
        0x00400300, 0x00800300, 0x00c00300, 0x00000400, 0x00400400, 0x00800400,
        0x00c00400, 0x00000500, 0x00400500, 0x00800500, 0x00c00500, 0x00000600,
        0x00400600, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x00800600, 0x00c00600, 0x00000700, 0x00400700, 0x00800700,
        0x00c00700, 0x00000800, 0x00400800, 0x00800800, 0x00c00800, 0x00000900,
        0x00400900, 0x00800900, 0x00c00900, 0x00000a00, 0x00400a00, 0x00800a00,
        0x00c00a00, 0x00000b00, 0x00400b00, 0x00800b00, 0x00c00b00, 0x00000c00,
        0x00400c00, 0x00800c00, 0x00c00c00, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff
    )
    let p = DTypePointer[DType.uint32].alloc(256)
    p.simd_store(d)
    return p

alias d3 = compute_d3()

fn compute_d3() -> DTypePointer[DType.uint32]:
    let d = SIMD[DType.uint32, 256](
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x003e0000, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x003f0000,
        0x00340000, 0x00350000, 0x00360000, 0x00370000, 0x00380000, 0x00390000,
        0x003a0000, 0x003b0000, 0x003c0000, 0x003d0000, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x00000000,
        0x00010000, 0x00020000, 0x00030000, 0x00040000, 0x00050000, 0x00060000,
        0x00070000, 0x00080000, 0x00090000, 0x000a0000, 0x000b0000, 0x000c0000,
        0x000d0000, 0x000e0000, 0x000f0000, 0x00100000, 0x00110000, 0x00120000,
        0x00130000, 0x00140000, 0x00150000, 0x00160000, 0x00170000, 0x00180000,
        0x00190000, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x001a0000, 0x001b0000, 0x001c0000, 0x001d0000, 0x001e0000,
        0x001f0000, 0x00200000, 0x00210000, 0x00220000, 0x00230000, 0x00240000,
        0x00250000, 0x00260000, 0x00270000, 0x00280000, 0x00290000, 0x002a0000,
        0x002b0000, 0x002c0000, 0x002d0000, 0x002e0000, 0x002f0000, 0x00300000,
        0x00310000, 0x00320000, 0x00330000, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff,
        0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff
    )
    let p = DTypePointer[DType.uint32].alloc(256)
    p.simd_store(d)
    return p

@always_inline
fn decode[zero_terminated: Bool = False](input: String) raises -> (DTypePointer[DType.uint8], Int):
    var input_size = len(input)
    var input_pointer = input._as_ptr().bitcast[DType.uint8]()
    if input_size == 0:
        return DTypePointer[DType.uint8](), 0
    
    if input_size & 3 != 0:
        raise "We do not support unpadded base64 strings"
    
    # input size without padding
    input_size -= (input_pointer.load(input_size - 2) == cpad).to_int() + (input_pointer.load(input_size - 1) == cpad).to_int()

    var result_size = (input_size >> 2) * 3
    @parameter
    if zero_terminated:
        result_size += 1
    let result = DTypePointer[DType.uint8].alloc(result_size)

    let leftover = input_size & 3
    let chunks = input_size >> 2
    
    var bad_char = False
    var destination = result
    for i in range(chunks):
        let x = d0[input_pointer[0].to_int()] | d1[input_pointer[1].to_int()] | d2[input_pointer[2].to_int()] | d3[input_pointer[3].to_int()]
        bad_char = bad_char | x >= BADCHAR
        let xu8 = bitcast[DType.uint8, 4](x)
        destination.store(xu8[0])
        destination.store(1, xu8[1])
        destination.store(2, xu8[2])
        destination = destination.offset(3)
        input_pointer = input_pointer.offset(4)
    
    if leftover == 2:
        let x = d0[input_pointer[0].to_int()] | d1[input_pointer[1].to_int()]        
        bad_char = bad_char | x >= BADCHAR
        let xu8 = bitcast[DType.uint8, 4](x)
        destination.store(xu8[0])
        result_size += 1
    elif leftover == 3:
        let x = d0[input_pointer[0].to_int()] | d1[input_pointer[1].to_int()] | d2[input_pointer[2].to_int()]        
        bad_char = bad_char | x >= BADCHAR
        let xu8 = bitcast[DType.uint8, 4](x)
        destination.store(xu8[0])
        destination.store(1, xu8[1])
        result_size += 2

    if bad_char:
        raise "Could not decode. Bad char was identified"

    @parameter
    if zero_terminated:
        result[result_size - 1] = 0
    return result, result_size

@always_inline
fn _encode(
    input: DTypePointer[DType.uint8], length: Int, output: DTypePointer[DType.uint8]
):
    var processed = 0
    var p = output
    if length > 2:
        for i in range(0, length - 2, 3):
            let t1 = input.load(i).to_int()
            let t2 = input.load(i + 1).to_int()
            let t3 = input.load(i + 2).to_int()
            let bytes = SIMD[DType.uint8, 4](
                e0.load(t1),
                e1.load(((t1 & 0x03) << 4) | ((t2 >> 4) & 0x0F)),
                e1.load(((t2 & 0x0F) << 2) | ((t3 >> 6) & 0x03)),
                e1.load(t3),
            )
            p.simd_nt_store(bytes)
            p = p.offset(4)
            processed = i + 3

    let rest = length - processed
    if rest == 1:
        let t1 = input.load(processed).to_int()
        let bytes = SIMD[DType.uint8, 4](
            e0.load(t1), e1.load(((t1 & 0x03) << 4)), cpad, cpad
        )
        p.simd_nt_store(bytes)
    elif rest == 2:
        let t1 = input.load(processed).to_int()
        let t2 = input.load(processed + 1).to_int()
        let bytes = SIMD[DType.uint8, 4](
            e0.load(t1),
            e1.load(((t1 & 0x03) << 4) | ((t2 >> 4) & 0x0F)),
            e1.load(((t2 & 0x0F) << 2)),
            cpad,
        )
        p.simd_nt_store(bytes)


@always_inline
fn encode(input: StringLiteral) -> String:
    return encode(input.data().bitcast[DType.uint8](), len(input))


@always_inline
fn encode(input: String) -> String:
    return encode(input._as_ptr().bitcast[DType.uint8](), len(input))


@always_inline
fn encode(input: Tensor) -> String:
    return encode(input.data().bitcast[DType.uint8](), input.bytecount())


@always_inline
fn encode(input: DTypePointer[DType.uint8], length: Int) -> String:
    let data = input
    let result_size = (length + 2) // 3 * 4 + 1
    let result = DTypePointer[DType.int8].aligned_alloc(4, result_size)
    var offset = 0
    var cursor = result.bitcast[DType.uint8]()
    alias simd_width = 32
    while length - offset >= simd_width:
        let a = data.simd_load[simd_width](offset)
        # aaaaaabb bbbbcccc ccdddddd ________
        let b = a.shuffle[
            1,
            0,
            2,
            1,
            4,
            3,
            5,
            4,
            7,
            6,
            8,
            7,
            10,
            9,
            11,
            10,
            13,
            12,
            14,
            13,
            16,
            15,
            17,
            16,
            19,
            18,
            20,
            19,
            22,
            21,
            23,
            22,
        ]()
        # bbbbcccc aaaaaabb ccdddddd bbbbcccc

        offset += (simd_width >> 2) * 3

        let c = bitcast[DType.uint16, simd_width >> 1](b)

        let d = c.deinterleave()
        # d[0] = bbbbcccc aaaaaabb
        # d[1] = ccdddddd bbbbcccc

        # TODO: this implementaiton is for little endian only add big endian support

        let d1 = rotate_bits_left[6](d[0]).cast[DType.uint8]()
        # d1 = ccaaaaaa
        let d2 = rotate_bits_left[12](d[0]).cast[DType.uint8]()
        # d2 = aabbbbbb
        let d3 = rotate_bits_left[10](d[1]).cast[DType.uint8]()
        # d3 = bbcccccc
        let d4 = d[1].cast[DType.uint8]()
        # d4 = ccdddddd

        let e1 = d1.interleave(d3)
        # e1 = ccaaaaaa bbcccccc
        let e2 = d2.interleave(d4)
        # e2 = aabbbbbb ccdddddd
        let e3 = e1.interleave(e2) & 0b0011_1111
        # e3 = 00aaaaaa 00bbbbbb 00cccccc 00dddddd

        let upper = e3 < 26
        let lower = (e3 > 25) & (e3 < 52)
        let nums = (e3 > 51) & (e3 < 62)
        let plus = e3 == 62
        let slash = e3 == 63

        let f1 = upper.select(e3 + 65, 0)
        let f2 = lower.select(e3 + 71, 0)
        let f3 = nums.select(e3 - 4, 0)
        let f4 = plus.select(e3 - 19, 0)
        let f5 = slash.select(e3 - 16, 0)

        #  0 .. 25 -> 65 .. 90    (+65) A .. Z
        # 26 .. 51 -> 97 .. 122   (+71) a .. z
        # 52 .. 61 -> 48 .. 57    (-4)  0 .. 9
        # 62       -> 43          (-19) +
        # 63       -> 47          (-16) /

        cursor.simd_nt_store(0, f1 + f2 + f3 + f4 + f5)

        cursor = cursor.offset(simd_width)

    if length > offset:
        _encode(data.offset(offset), length - offset, cursor)

    result.store(result_size - 1, 0)
    return String(result, result_size)
