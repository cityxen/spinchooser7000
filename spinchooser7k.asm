//////////////////////////////////////////////////////////////////////////////////////
// SPIN CHOOSER 7K 
// C64/128 Joystick routine
//////////////////////////////////////////////////////////////////////////////////////
#import "../Commodore64_Programming/include/Constants.asm"
#import "../Commodore64_Programming/include/DrawPetMateScreen.asm"

// Local Constants

.const FLASH_TIMER_SPEED_CONST = $80

.const BUTTON_RED    = $FB
.const BUTTON_GREEN  = $FE
.const BUTTON_YELLOW = $FD
.const BUTTON_BLUE   = $F7
.const BUTTON_WHITE  = $EF

.const BUTTON_LIGHT_RED    = %11110111
.const BUTTON_LIGHT_GREEN  = %11111110
.const BUTTON_LIGHT_YELLOW = %11111101
.const BUTTON_LIGHT_BLUE   = %11111011
.const BUTTON_LIGHT_WHITE  = %11011111
.const BUTTON_LIGHT_ALL    = %00000000
.const BUTTON_LIGHT_NONE   = %11111111


.segment Sprites [allowOverlap]
*=$2000 "POINTER"
// #import "pointer.asm"
.segment Screens [allowOverlap]
*=$3000 "SCREENS"
#import "petmate/screens.asm"
//////////////////////////////////////////////////////////////////////////////////////
// File stuff
.file [name="sc7k.prg", segments="Main,Sprites,Screens"]
.disk [filename="sc7k.d64", name="CITYXEN SC7K", id="2023!" ] {
	[name="SC7K", type="prg",  segments="Main,Sprites,Screens"],
    [name="--------------------",type="del"],
}
//////////////////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
* = $0801 "BASIC"
.word usend // link address
.word 2023  // line num
.byte $9e   // sys
.text toIntString(init)
.byte $3a,99,67,73,84,89,88,69,78,99
usend:
.byte 0
.word 0  // empty link signals the end of the program
* = $0830 "vars init"

init:

// reset user port values to output and zero
lda #$ff
sta USER_PORT_DATA_DIR
lda #$00
sta flash_value
lda #FLASH_TIMER_SPEED_CONST
sta flash_timer_speed
sta USER_PORT_DATA

DrawPetMateScreen(screen_001)

main:

lda JOYSTICK_PORT_1 // read joystick port 1
and #16

lda JOYSTICK_PORT_2 // read joystick port 2
and #$10
bne !jp2+
// fire button hit
 
jsr select_buttons
jmp main

!jp2:
lda JOYSTICK_PORT_2 // read joystick port 2
and #$0f

bne !jp2+

// 00

!jp2:
cmp #$01
bne !jp2+

// 01

!jp2:
cmp #$02
bne !jp2+

// 02

!jp2:
cmp #$03
bne !jp2+

// 03

!jp2:
cmp #$04
bne !jp2+

// 04

!jp2:
cmp #$05
bne !jp2+

// 05

!jp2:
cmp #$06
bne !jp2+

// 06

!jp2:
cmp #$07
bne !jp2+

// 07

!jp2:
cmp #$08
bne !jp2+

// 08

!jp2:
cmp #$09
bne !jp2+

// 09

!jp2:
cmp #$0a
bne !jp2+

// 10

!jp2:
cmp #$0b
bne !jp2+

// 11

!jp2:
cmp #$0c
bne !jp2+

// 12

!jp2:
cmp #$0d
bne !jp2+

// 13

!jp2:
cmp #$0e
bne !jp2+

// 14

!jp2:
cmp #$0f
bne !jp2+

// 15

!jp2:



jmp main


select_buttons:

DrawPetMateScreen(screen_002)


select_buttons_loop:


// increment flash timer for buttons
inc flash_timer
bne !sbl+
inc flash_timer2
lda flash_timer2
cmp flash_timer_speed
bne !sbl+

// check flash timer for flash increment
lda #$00
sta flash_timer
sta flash_timer2

inc flash_value_count
lda flash_value_count
and #$01
tax
lda flash_value_1,x
sta USER_PORT_DATA
// sta $040f // debug

!sbl:
// check joystick port 1 values

lda JOYSTICK_PORT_1
// pha
// PrintHex(1,1)
// pla
cmp #$ff
beq select_buttons_loop

cmp #BUTTON_BLUE
bne !chk_buttons+
lda #BUTTON_LIGHT_BLUE
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_RED
bne !chk_buttons+
lda #BUTTON_LIGHT_RED
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_GREEN
bne !chk_buttons+
lda #BUTTON_LIGHT_GREEN
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_YELLOW
bne !chk_buttons+
lda #BUTTON_LIGHT_YELLOW
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_WHITE
bne !chk_buttons+
lda #BUTTON_LIGHT_WHITE
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:

exit_select_button:
rts

arrow_slice:
.byte 0


up:     .byte 0
down:   .byte 0
left:   .byte 0
right:  .byte 0
button: .byte 0

up2:     .byte 0
down2:   .byte 0
left2:   .byte 0
right2:  .byte 0
button2: .byte 0

page_table:
.text "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.byte 0
question_table:
.text "1234567890"
.byte 0

flash_timer:
.byte 0
flash_timer2:
.byte 0
flash_timer3:
.byte 0
flash_timer_speed:
.byte FLASH_TIMER_SPEED_CONST
flash_value:
.byte 0
flash_value_count:
.byte 0
flash_value_1:
.byte %010101010
flash_value_2:
.byte %101010101



#import "../Commodore64_Programming/include/PrintSubRoutines.asm"