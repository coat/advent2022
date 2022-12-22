#target rom

; https://www.msx.org/wiki/Main-ROM_BIOS
CHPUT     .equ $00a2     ; Address of character output routine in MSX-BIOS
INIT32    .equ $006f
LINL32    .equ $0f3af

#code HEADER, 0x4000
; These first few bytes are the ROM header used by the Main BIOS to boot the cartridge

.dm "AB"  ; ID for auto-executable ROM
.dw start ; Main program execution address.
.dw 0     ; STATEMENT
.dw 0     ; DEVICE
.dw 0     ; TEXT
.dw 0,0,0 ; Reserved

#code INIT, *, 0x8000 - HEADER_size

start:
     ld   a,32
     ld   (LINL32),a     ; 32 columns
     call INIT32         ; SCREEN 1

     call start_day

     ld   hl,output_msg
     call print

     ld   hl,MOST_CALS + 3
     ld   b,CAL_TOTAL_BYTES
byte_loop:
     ld   a,(hl)
     call print_hex_byte
     dec  hl
     djnz byte_loop

loop:
     jr loop

print:
     ld   a,(hl)    ; load the byte from memory
     and  a         ; same as CP 0 but faster.
     ret  z         ; return if we hit 0 byte
     call CHPUT     ; call the MSX BIOS routine to display a character.
     inc  hl        ; point to the next character
     jr   print     ; keep printing characters until we hit 0

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
     call CHPUT
     ret

output_msg:
     db "Most calories: $",0

#include "day1.asm"
#end
