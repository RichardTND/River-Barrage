;River Barrage picture + music linker
;fade-in and fade-out intro 

;by Richard Bayliss


colour_data = $4328
video_data = $3f40

	;Generate picture linker
    !to "rbpiclinker.prg",cbm 
    
	;Setup up SYS 2061 
	
	*=$0801
	!byte $0b,$08,$e8,$07,$9e,$32,$30,$36,$31,$00,$00,$00,$00,$00,$00


	;Main code for linker
    * = $080d ; Code for picture linker 

    sei

;Switch on IRQs 
   
    ldx #<irq
    ldy #>irq 
    lda #$7f
    stx $0314
    sty $0315
    sta $dc0d 
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$2e
    sta $d012
    lda #$1b
    sta $d011
    lda #$01
    sta $d01a 
    lda #$00
    jsr $1000
    cli 
    jmp intromain

;Main IRQ interrupt for playing the 
;loader tune.

irq asl $d019 
    lda $dc0d 
    sta $dd0d 
    lda #$fa 
    sta $d012
    jsr $1003
    jmp $ea7e 

;Main code to setup the picture 
;display

intromain 
   
	;Setup VIC2 hardware values as 
	;multicolour bitmap 
	
    lda #$3b
    sta $d011
    lda #$18
    sta $d018
    sta $d016 
    lda #$00
    sta $d020  
    sta $d015
    lda $4170
    sta $d021
    lda #$03
    sta $dd00
	
	;Fill the entire screen with white
	;this includes the picture's video 
	;and colour RAM.
	
    ldx #$00
whitall
    lda #$11
    sta $0400,x
    sta $0500,x
    sta $0600,x 
    sta $06e8,x 
    sta $d800,x 
    sta $d900,x 
    sta $da00,x 
    sta $dae8,x 
    inx 
    bne whitall    
	
	;Create a transition that will 
	;draw the picture onto screen 
	;using a "dissolve in" effect.
	
    ldx #$00
drawloop1
    ldy #$00
drawloop2 
    lda video_data,x 
    sta $0400,x 
    lda video_data+$100,x
    sta $0500,x 
    lda video_data+$200,x 
    sta $0600,x 
    lda video_data+$2e8,x 
    sta $06e8,x 
    lda colour_data,x 
    sta $d800,x 
    lda colour_data+$100,x 
    sta $d900,x 
    lda colour_data+$200,x 
    sta $da00,x 
    lda colour_data+$2e8,x
    sta $dae8,x
    iny
    bne drawloop2
    inx 
    inx 
    inx 
    bne drawloop1
	
	;The picture is drawn. Wait for 
	;the user to press spacebar or 
	;fire.
	
waitloop 
	;Await spacebar press or fire in 
	;port 1 (linked)
	
	lda #16
    bit $dc01 
    bne waitloop2
    jmp leavepic 
	
	
waitloop2 
    ;Await fire in port 2 press
	lda #16
    bit $dc00
    bne waitloop 
    jmp leavepic 

	;Space or fire has been pressed so
	;generate a transition effect as 
	;we did before, but this time make
	;the picture dissolve out as white
	
leavepic 
    ldx #$00
clearout
    ldy #$00
clearout2 
    lda #$11
    sta $d800,x 
    sta $d900,x 
    sta $da00,x 
    sta $dae8,x 
    lda #$11
    sta $0400,x 
    sta $0500,x 
    sta $0600,x 
    sta $06e8,x 
    iny 
    bne clearout2
    inx 
    inx 
    inx
    bne clearout
	
	;Revert to default C64 VIC2 mode 
	
	
    lda #$14
    sta $d018 
    lda #$08
    sta $d016
    lda #$1b
    sta $d011 
	
	;Fill the screen ram with inverted 
	;space character ($a0) 
	
    ldx #$00
zerofill
    lda #$a0
    sta $0400,x 
    sta $0500,x 
    sta $0600,x 
    sta $06e8,x 
    inx 
    bne zerofill
	
	;Now create a transition that will
	;change the white inverted space 
	;characters into black characters 
	;to make it look as if the screen 
	;is blacking out.
	
    ldx #$00
blackout 
    ldy #$00
blackout2 
    lda #$00
    sta $d800,x 
    sta $d900,x 
    sta $da00,x 
    sta $dae8,x
    iny 
    bne blackout2 
    inx 
    inx 
    inx 
    bne blackout 

	;A small loop to make music fade 
	;out. (If using Goat Tracker or 
	;GT Ultra, make sure music volume
	;support is set otherwise this 
	;trick will not work).

;Music fader routine 
    lda #$0f 
    sta fadedelay
WaitingLoop
    ldx #$00
WaitingLoop2    
    ldy #$00
WaitingLoop3    
    iny 
    bne WaitingLoop3
    inx
    bne WaitingLoop2
    dec fadedelay
    lda fadedelay
    ;Volume has reached 0
	cmp #0
    beq finishedmusicfade 
    jsr $1006
    jmp WaitingLoop 
finishedmusicfade

; Kill off all IRQ raster interrupts 		
; and completely clear the SID 
    sei
    ldx #$31
    ldy #$ea 
    lda #$81 
    stx $0314
    sty $0315
    sta $dc0d 
    sta $dd0d 
    lda $dc0d 
    lda $dd0d 
    lda #$00
    sta $d01a 
    ldx #$00
clearsid
    lda #$00
    sta $d400,x 
    inx 
    cpx #$18
    bne clearsid 
   ; jsr $ff81 
   
    lda #0
    sta $d020 
    sta $d021
	
;Setup the transfer routine and then 
;jump right into the main transfer
;code placed into the screen RAM.
	
    ldx #$00
grabtransfer 
    lda transfer,x 
    sta $0400,x
    lda #0
    sta $d800,x 
    sta $d900,x 
    sta $da00,x 
    sta $dae8,x
    inx 
    bne grabtransfer    
    cli 
    jmp $0400
	
;Main code transfer routine. Reads 
;the position of where the game 
;is and then moves it to BASIC memory
;using self-modifying code. $34 is set 
;to allow all memory usage during this 
;process. 	
	
transfer 
    sei 
    lda #$34
    sta $01 
tloop1  ldx #$00    
tloop2 lda data,x 
       sta $0801,x 
       inx 
       bne tloop2 
       inc $0409
       inc $040c
       lda $0409 
       bne tloop2 
	   
;Switch back to kernal mode, clear 
;the flag and execute a basic run.
	   
       lda #$37
       sta $01
       cli 
       jsr $a659
       jmp $a7ae

;Volume fade out byte 
fadedelay !byte $00

;--------------------------------------
;C64 files

	;Import loading music data 
    *=$1000
    !bin "c64/loadertune.prg",,2
	
	;Import loading bitmap
    *=$2000
    !bin "c64/riverpic.kla",,2
	
	;Import compiled/crunched game
    *=$4800
data !bin "riverbarrage.prg",,2    
;--------------------------------------

;Finished :)