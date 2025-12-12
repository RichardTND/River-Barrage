;New title screen IRQ setup (Based on original River Barrage IRQ code)
          
            sei 
            ldx #$fb 
            txs
            ldx #<IRQ1
            ldy #>IRQ1
            stx $fffe 
            sty $ffff  
            lda #$01 
            sta $d01a 
            sta $d019 
            ldx #<NMI 
            ldy #>NMI 
            stx $fffa 
            sty $fffb 
            lda #$7f 
            sta $dc0d 
            sta $dd0d 
            lda $dc0d 
            lda $dd0d 
            lda #$32 
            sta $d012 
            lda #$1b 
            sta $d011 
            lda #0
	        sta IRQ_InGameMode
            lda #<scrolltext 
            sta messread+1
            lda #>scrolltext 
            sta messread+2 
            lda #2 
            sta SCROLLSPEED+1
            cli 
            jmp TitleLoop

IRQ1        sta stacka1+1
            stx stackx1+1
            sty stacky1+1
            asl $d019 
            lda $dc0d 
            sta $dd0d
            lda #$2a
            sta $d012
            lda #$18
            sta $d016
            
          
            lda #1
            sta rt
            jsr MusicPlayerPlay
            ldx #<IRQ2             
            ldy #>IRQ2
            stx $fffe
            sty $ffff
stacka1     lda #$00
stackx1     ldx #$00
stacky1     ldy #$00            
            rti 
IRQ2                 
            sta stacka2+1
            stx stackx2+1
            sty stacky2+1
            asl $d019 
            lda #$f2
            sta $d012 
            ldy $d012 
            ldx #79
loop1       lda d016table,x 
            cpy $d012 
            beq *-3 
            sta $d016 
            iny
            dex 
            bpl loop1 
            lda #$08 
            sta $d016            
            
            ldx #<IRQ3
            ldy #>IRQ3 
            stx $fffe 
            sty $ffff
stacka2     lda #$00
stackx2     ldx #$00
stacky2     ldy #$00
            rti

IRQ3        sta stacka3+1
            stx stackx3+1
            sty stacky3+1

            asl $d019      
            lda #$fa 
            sta $d012      
            
            lda xpos 
            sta $d016
           
            ldx #<IRQ1
            ldy #>IRQ1 
            stx $fffe
            sty $ffff 
stacka3     lda #$00
stackx3     ldx #$00
stacky3     ldy #$00            
            
NMI         rti                        
;Kill IRQ and SID chip routines 

KillIRQ     sei 
           
            lda #$00
            sta $d019 
            sta $d01a 
            sta $d015
            lda #$81
            sta $dc0d
            sta $dd0d 
            ;lda #$48
            ;sta $fffe
            ;lda #$ff 
            ;sta $ffff


            ldx #$00
NoSID       lda #$00
            sta $d400,x             
            inx 
            cpx #$18
            bne NoSID
            ;Small delay routine 

            lda #0
            sta pagedelay
            sta pagedelay+1
            cli
            rts 


;Single IRQ for Game Over, End and Hi Score 

SetupSingleIRQ
            ldx #<SingleIRQ
            ldy #>SingleIRQ 
            lda #$7f 
            stx $fffe
            sty $ffff
            sta $dc0d 
            sta $dd0d 
            lda $dc0d
            lda $dd0d
            ldx #<NMI
            ldy #>NMI
            stx $fffa
            sty $fffb 
            lda #$2a
            sta $d012 
            lda #$1b
            sta $d011 
            lda #$01
            sta $d01a 
            sta $d019

            cli 
            rts
SingleIRQ   sta singlestacka+1
            stx singlestackx+1
            sty singlestacky+1
            asl $d019 

            lda #$f8 
            sta $d012 
            lda #$08
            sta $d016
            lda #$12
            sta $d018 
            lda #$03
            sta $dd00
            lda #1
            sta rt 
            jsr MusicPlayerPlay
singlestacka
            lda #0
singlestackx
            ldx #0
singlestacky            
            ldy #0
            rti
