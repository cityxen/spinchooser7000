//////////////////////////////////////////////////////////////////////////////////////
// SPIN CHOOSER 7K for C64
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


//////////////////////////////////////////////////////////////////
// Initialization
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
// TODO: set up sound

//////////////////////////////////////////////////////////////////
// Main loop
main:

///////////////////////////////////
// enter button selection mode by hitting F1
jsr KERNAL_GETIN
cmp #KEY_F1
bne !ml+
jsr select_buttons
jmp main

!ml:

///////////////////////////////////
// determine if wheel is spinning or not
lda pointer_current
cmp #pointer_old
beq main // wheel not spinning

///////////////////////////////////
// If FIRE (J2) then play sound
lda JOYSTICK_PORT_2
and #%00010000
bne !ml+
jsr play_peghit
jmp main

!ml:
lda JOYSTICK_PORT_2 // read joystick port 2
and #$0f

jmp main

//////////////////////////////////////////////////////////////////
// FLASH THE BUTTONS, CHECK FOR BUTTON SELECTION
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
!sbl:
// check joystick port 1 values
lda JOYSTICK_PORT_1
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

//////////////////////////////////////////////////////////////////
// peghit sound

play_peghit:

rts

//////////////////////////////////////////////////////////////////
// VARS

pointer_current:        .byte 0
pointer_old:            .byte 0
wheel_spinning:         .byte 0
wheel_spinning_timeout: .byte 0
up:                     .byte 0
down:                   .byte 0
left:                   .byte 0
right:                  .byte 0
button:                 .byte 0
up2:                    .byte 0
down2:                  .byte 0
left2:                  .byte 0
right2:                 .byte 0
button2:                .byte 0
flash_timer:            .byte 0
flash_timer2:           .byte 0
flash_timer3:           .byte 0
flash_timer_speed:      .byte FLASH_TIMER_SPEED_CONST
flash_value:            .byte 0
flash_value_count:      .byte 0
flash_value_1:          .byte %010101010
flash_value_2:          .byte %101010101

page_table:
.text "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
.byte 0
question_table:
.text "1234567890"
.byte 0

#import "../Commodore64_Programming/include/PrintSubRoutines.asm"