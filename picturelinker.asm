;River Barrage picture + music linker

colour_data = $4328
video_data = $3f40


    !to "rbpiclinker.prg",cbm 
    *=$0801
!byte $0b,$08,$e8,$07,$9e,$32,$30,$36,$31,$00,$00,$00,$00,$00,$00

    * = $080d ; Code for picture linker 

    sei
   
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

irq asl $d019 
    lda $dc0d 
    sta $dd0d 
    lda #$fa 
    sta $d012
    jsr $1003
    jmp $ea7e 

intromain 
   
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
waitloop 
    lda #16
    bit $dc01 
    bne waitloop2
    jmp leavepic 
waitloop2 
    lda #16
    bit $dc00
    bne waitloop 
    jmp leavepic 

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
    lda #$14
    sta $d018 
    lda #$08
    sta $d016
    lda #$1b
    sta $d011 
    ldx #$00
zerofill
    lda #$a0
    sta $0400,x 
    sta $0500,x 
    sta $0600,x 
    sta $06e8,x 
    inx 
    bne zerofill
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

;Music fader routine 
    lda #$0f 
    sta $fe
WaitingLoop
    ldx #$00
WaitingLoop2    
    ldy #$00
WaitingLoop3    
    iny 
    bne WaitingLoop3
    inx
    bne WaitingLoop2
    dec $fe 
    lda $fe 
    cmp #$00
    beq finishedmusicfade 
    jsr $1006
    jmp WaitingLoop 
finishedmusicfade

    

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
       lda #$37
       sta $01
       cli 
       jsr $a659
       jmp $a7ae




    *=$1000
    !bin "c64/loadertune.prg",,2
    *=$2000
    !bin "c64/loaderpic.kla",,2
    *=$4800
data !bin "riverbarrage.prg",,2    


