LF                  equ  $0a
ETX                 equ  4
CAL_TOTAL_BYTES     equ  4    ; individual calorie entries seem to be under 16-bit, but 
                              ; the totals can exeed that - 32-bit (4 bytes) seems plenty

MOST_CALS           equ  $c000                         ; current highest calorie total
ELF_TOTAL           equ  MOST_CALS + CAL_TOTAL_BYTES   ; temp space to hold current elf's total calories

start_day:
     ld   hl,ascii_calories   ; load the address of where our input starts
     ld   de,0
     ld   bc,0

     ld   (ELF_TOTAL),bc      ; ensure memory is zeroed out
     ld   (ELF_TOTAL + 2),bc
     ld   (MOST_CALS),bc
     ld   (MOST_CALS + 2),bc

next_char:
     ld   a,(hl)              ; get the first ascii char
     cp   ETX                 ; end of input?
     ret  z                   ; done with our elves

     cp   LF                  ; is char a line feed?
     jr   z,add_to_total      ; add to current elf's calorie total

ascii2bin:                    ; loop and keep multiplying by 10 and adding new digits
     sub  '0'                 ; convert ascii code to binary value
     push hl                  ; we need hl for 16-bit addition so save pointer
     
     ld   h,d                 ; there is no ld hl,de (but zasm will expand it)
     ld   l,e

                              ; no multiplication on the Z80, but by bit shifting we
                              ; can multiply by 10: (n * 8) + (n * 2)
     add  hl,hl               ; double the value effectively shifts left
     add  hl,hl
     add  hl,de
     add  hl,hl

     ld   c,a                 ; add current digit in the ones place
     add  hl,bc
     ex   de,hl               ; quicker than ld d,h; ld e,l

     pop  hl                  ; restore input file pointer

     inc  hl                  ; point to next character
     jr   next_char

add_to_total:
     push hl

     or   a                   ; reset carry flag
     ld   hl,(ELF_TOTAL)      ; least signifact word
     add  hl,de
     ld   (ELF_TOTAL),hl

     ld   hl,(ELF_TOTAL + 2)  ; most significant word
     ld   bc,0
     adc  hl,bc               ; individual calorie amounts are always(?) 16-bit, but add the carry bit
                              ; if previous addition carried over
     ld   (ELF_TOTAL + 2),hl

     pop  hl                  ; restore pointer

     ld   de,0                ; reset current calorie entry

     inc  hl                  ; let's check to see if we are done with this elf
     ld   a,(hl)
     cp   LF                  ; is char a line feed again?
     jr   z,calc_elf_total    ; we are done with our elf's calories

     jr   next_char           ; we've already incremented hl

calc_elf_total:
     push hl                  ; we need these register pairs, so save contents to stack
     push de

     ld   de,MOST_CALS + 3    ; start with the most significant bytes
     ld   hl,ELF_TOTAL + 3    ; our 32-bit numbers are stored little-endian, so start with the last byte
     ld   b,CAL_TOTAL_BYTES   ; we are going to loop through each byte and compare

compare_loop:
     ld   a,(de)              
     cp   (hl)
     jr   c, new_most_cals    ; carry flag is set if ELF_TOTAL byte > MOST_CALS byte

     jr   nz, compare_exit    ; if ELF_TOTAL != MOST_CALS, then MOST_CALS is higher so bail out
                              ; otherwise, they will be equal, so we need to move on to the next byte
     dec  hl                  ; point to next MSB ELF_TOTAL byte
     dec  de                  ; point to next MSB MOST_CALS byte
     djnz compare_loop        ; this decrements b, and jumps to label if b != 0

     jr   compare_exit        ; we are out of bytes - they must be the same

new_most_cals:
     ld   hl,(ELF_TOTAL)      ; replace current high total with this elves
     ld   (MOST_CALS),hl
     ld   hl,(ELF_TOTAL + 2)
     ld   (MOST_CALS + 2),hl

compare_exit:
     pop  de                  ; restore registers we used
     pop  hl

     ld   bc,0                ; reset ELF_TOTAL to 0 for next elf
     ld   (ELF_TOTAL),bc
     ld   (ELF_TOTAL + 2),bc

     inc  hl                  ; point to next char

     jr   next_char

ascii_calories:
#insert "input.txt"
.db   LF,ETX    ; marks the end of input (ETX ascii code)
