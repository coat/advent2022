#target rom

#code CODE
#include "day1.asm"

CON_IO  equ 0xfe        ; a port address
#test find_thiccest_elf, 0x9000
#local
     .test-console CON_IO     ; test runner will print to STDOUT - nice!

     call start_day

     ld   de,(MOST_CALS + 2)
     ld   hl,(MOST_CALS)

     .expect dehl = 67633     ; 

     jr   print_total

print_hex_byte:
    push af
    rrca \ rrca \ rrca \ rrca ; shift lower nibble to high
    call print_hex_char       ; print the first character
    pop  af

print_hex_char:
    and 0x0f
    cp  10                    
    jr  c,1$                  ; less than 10, just print the ascii num
    add 'A' - ('9'+1)

1$: add '0'
    call console_out
    ret

console_out:                  
     out (CON_IO),a           ; send a byte to STDOUT
     ret

print_total:                  ; it's just easier to display > 8-bit values in hex
     ld   hl,MOST_CALS + 3
     ld   b,CAL_TOTAL_BYTES
byte_loop:
     ld   a,(hl)
     call print_hex_byte
     dec  hl
     djnz byte_loop
#endlocal

#test ascii_to_binary_works, 0x8000
#local
     ld   hl,test_num
     ld   bc,0
     ld   de,0

     jr   start_test
test_num:
     .db  '1','2','3','4','5',ETX

start_test:
     call next_char

     .expect a = ETX
     .expect hl = test_num + 5
     .expect de = 12345
     .expect bc = 5
#endlocal
#end
