;Text depack linker for DALI crunched files.

            !to "riverbarragefinal.prg",cbm

            *=$0801 
            !byte $0b,$08,$e8,$07,$9e,$32,$30,$36,$31,$00,$00,$00,$00
            *=$080d
            jmp depacktxtdisplayer

DecrunchText
            !scr "-bringing the new dimension to your c64!-"
depacktxtdisplayer
            sei 
            lda #$37
            sta $01
            lda #$00
            sta $d020
            sta $d021
            lda #$05
            jsr $ffd2 
            jsr $e544
            ldx #$00
copydecrunchtext
            lda DecrunchText,x 
            sta $0400,x 
            inx 
            cpx #$28
            bne copydecrunchtext

;data        !bin "riverbarragedisk.prg",,2
            