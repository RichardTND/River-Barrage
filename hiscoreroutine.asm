scorelen = 6
listlen = 10
namelen = 9


;Hi score check routine 
!align $ff,$00

HiScoreChecker
   ; jsr KillIRQ
    jsr ClearScreen
   

    ;Convert player 1 and player 2 
    ;score bytes into figures 

    ldx #$00
convfigs 
    lda ScorePlayer1,x 
    clc 
    adc #$30
    sta Player1Score,x 
    lda ScorePlayer2,x 
    clc
    adc #$30 
    sta Player2Score,x 
    inx 
    cpx #$06
    bne convfigs 

    lda #0 
    sta namefinished 
    sta $02 

;Some custom settings and two hi score checks 


;PLAYER 1 CHECKS 

    ldx #$00    
player1readcopy 
    lda p1hslo,x 
    sta hslo,x 
    lda p1hshi,x 
    sta hshi,x 
    lda p1nmlo,x 
    sta nmlo,x 
    lda p1nmhi,x 
    sta nmhi,x 
    inx 
    cpx #10
    bne player1readcopy 

    lda #$31
    sta playerno

    lda #$01 ;White text for player 1 
    sta txtcol+1

    lda #$00
    sta joyport+1
    sta hi_fire+1

    ldx #$00
copyp1score 
    lda Player1Score,x 
    sta score,x 
    inx 
    cpx #6
    bne copyp1score 
    lda #0
    sta firebutton
    sta namefinished
    jsr HiScoreCheckRoutine

;Now do with player 2        

    ldx #$00
player2readcopy
    lda p2hslo,x 
    sta hslo,x 
    lda p2hshi,x 
    sta hshi,x 
    lda p2nmlo,x 
    sta nmlo,x 
    lda p2nmhi,x 
    sta nmhi,x 
    inx 
    cpx #10
    bne player2readcopy 

    lda #$01 
    sta joyport+1
    sta hi_fire+1
    lda #$32
    sta playerno

    lda #$07 
    sta txtcol+1
    ldx #$00
copyp2score 
    lda Player2Score,x 
    sta score,x 
    inx 
    cpx #6
    bne copyp2score 
    lda #0 
    sta firebutton
    sta namefinished
    jsr HiScoreCheckRoutine    
    lda #0
    sta sequence 
    jsr fadeoutmode
    jmp DisplayTitleScreen

HiScoreCheckRoutine 
        
              ldx #$00
nextone            lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
                    
                  
                    ldy #$00
scoreget           lda score,y
scorecmp           cmp ($c1),y
                    bcc posdown
                    beq nextdigit
                    bcs posfound
nextdigit          iny
                    cpy #scorelen
                    bne scoreget
                    beq posfound
posdown            inx
                    cpx #listlen
                    bne nextone
                    beq nohiscor
posfound           stx $02
                    cpx #listlen-1
                    beq lastscor
                                      
                    ldx #listlen-1
copynext           lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
                    lda nmlo,x
                    sta $d1
                    lda nmhi,x
                    sta $d2
                    dex
                    lda hslo,x
                    sta $c3
                    lda hshi,x
                    sta $c4
                    lda nmlo,x
                    sta $d3
                    lda nmhi,x
                    sta $d4
                   ; //Copy the scores from one zero page to 
                   ; //another. (which acts as a temp zp)
                    ldy #scorelen-1
copyscor           lda ($c3),y
                    sta ($c1),y
                    dey
                    bpl copyscor 
                   ; //Do the same with the name. Since the names should move 
                    ;//if a position is found.
                    ldy #namelen+1
copyname           lda ($d3),y
                    sta ($d1),y
                    dey
                    bpl copyname
                    cpx $02
                    bne copynext
                    
lastscor           ldx $02
                    lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
                    lda nmlo,x
                    sta $d1
                    lda nmhi,x
                    sta $d2
                    jmp nameentry
placenewscore                      
                    ldy #scorelen-1
putscore            lda score,y
                    sta ($c1),y
                    dey
                    bpl putscore    
                    ldy #namelen-1
putname             lda name,y
                    sta ($d1),y 
                    dey
                    bpl putname
        
nohiscor     rts


;Main name entry routine 
            
nameentry   
            lda #$0f 
            jsr MusicInit+6
            lda #2
            jsr MusicInit    
            jsr ClearScreen
            ;Output WELL DONE text
		   
           ldx #$00
outputmessage
           lda HiScoreText,x
           sta $0400+(9*40),x
           lda HiScoreText+(1*40),x
           sta $0400+(11*40),x
txtcol     lda #1
           sta $d800+(9*40),x 
           sta $d800+(11*40),x 
           sta $da3f,x           
           inx
           cpx #40
           bne outputmessage
		   
		   
 
           ;clear name output
           ldx #$00
clearnameoutput
           lda #$20
           sta name,x
           inx 
           cpx #9
           bne clearnameoutput
           
           ;Set character A as default char 
           
           lda #$01
           sta $04 
           
           lda #0
           sta joydelay 
           
           ;Init character position
           
           lda #<name
           sta sm+1 
           lda #>name 
           sta sm+2 
          
           lda #1
           sta name
           sta hi_char
           
     
         
           
nameentryloop
           
          jsr SyncTimer
          jsr ColourCycle

           ;Display the name
           ldx #$00
showname   lda name,x
           sta $063f,x
           inx
           cpx #9
           bne showname
           ldx #$00
flashheader 
           lda colourstore3
           sta $d800+9*40,x 
           lda colourstore2
           sta $da30,x             
           inx 
           cpx #40 
           bne flashheader
           ;Check if name input has finished 
           
           lda namefinished 
           cmp #1
           beq stopnameentry
           jsr joycheck
           jmp nameentryloop 
           
           ;Name entry has finished, place new player score
           ;to hi score 
           
stopnameentry
           jmp placenewscore
           
           ;Joystick check routine
joycheck   lda hi_char
sm         sta name
           lda joydelay 
           cmp #6
           beq joyhiok
           inc joydelay 
           rts
           
joyhiok    lda #0
           sta joydelay
           
           ;Check joystick up
joyport    lda $dc90 
           lsr
           bcs hi_down 
           inc hi_char 
           lda hi_char
           
           ;Check for special characters 
           cmp #27
           beq delete_char 
           cmp #33
           beq a_char
           rts
           
           ;Check joy down 
hi_down    lsr
           bcs hi_fire 
           dec hi_char
           
           ;Check for unwanted characters 
           lda hi_char
           beq space_char
           cmp #29
           beq z_char 
           rts
           
           ;Make delet char
delete_char            
           lda #30
           sta hi_char
           rts 
           
           ;Make space char 
space_char lda #$20
           sta hi_char
           rts 
           
           ;Make char letter A 
a_char     lda #1
           sta hi_char
           rts 
           
           ;Make char letter Z
z_char     lda #26
           sta hi_char
           rts
           
           ;Check fire button 
hi_fire:   lda $dc00
           lsr 
           lsr
           lsr
           lsr
           lsr
           bit firebutton
           ror firebutton
           bmi no_fire
           bvc no_fire 
           
           ;Fire has been pressed, check for delete/end chars (back arrow)
           
           lda hi_char
           cmp #31
           bne checkendchar
           
           lda sm+1
           cmp #<name 
           beq donotgoback
           dec sm+1
           jsr cleanupname
donotgoback           
           rts
           
           ;Check for end char (Up arrow)
checkendchar           
           
          cmp #30
          bne charisok 
          
          ;End spotted so remove the character and replace with space 
          
          lda #$20
          sta hi_char
          
          jmp finished_now
charisok

          inc sm+1
          lda sm+1
          cmp #<name+9
          beq finished_now 
          lda #0
          sta firebutton
          rts
finished_now
          jsr cleanupname
          lda #1
          sta namefinished
          rts
          
cleanupname
          ldx #$00
clearchars
          lda name,x
          cmp #30
          beq cleanup 
          cmp #31
          beq cleanup
          jmp skipcleanup
cleanup   lda #$20
          sta name,x
skipcleanup
          inx
          cpx #namelen
          bne clearchars
no_fire          
          rts



joydelay !byte 0 
namefinished !byte 0
hi_char !byte 0

name         !byte $20,$20,$20,$20,$20,$20,$20,$20,$20
nameend      

Player1Score !byte $30,$30,$30,$30,$30,$30
Player2Score !byte $30,$30,$30,$30,$30,$30    
score        !byte $30,$30,$30,$30,$30,$30

hslo         !byte <p1hiscore1,<p1hiscore2,<p1hiscore3,<p1hiscore4,<p1hiscore5,<p1hiscore6,<p1hiscore7,<p1hiscore8,<p1hiscore9,<p1hiscore10
hshi         !byte >p1hiscore1,>p1hiscore2,>p1hiscore3,>p1hiscore4,>p1hiscore5,>p1hiscore6,>p1hiscore7,>p1hiscore8,>p1hiscore9,>p1hiscore10
nmlo         !byte <p1name1,<p1name2,<p1name3,<p1name4,<p1name5,<p1name6,<p1name7,<p1name8,<p1name9,<p1name10 
nmhi         !byte >p1name1,>p1name2,>p1name3,>p1name4,>p1name5,>p1name6,>p1name7,>p1name8,>p1name9,>p1name10 

p1hslo         !byte <p1hiscore1,<p1hiscore2,<p1hiscore3,<p1hiscore4,<p1hiscore5,<p1hiscore6,<p1hiscore7,<p1hiscore8,<p1hiscore9,<p1hiscore10
p1hshi         !byte >p1hiscore1,>p1hiscore2,>p1hiscore3,>p1hiscore4,>p1hiscore5,>p1hiscore6,>p1hiscore7,>p1hiscore8,>p1hiscore9,>p1hiscore10
p1nmlo         !byte <p1name1,<p1name2,<p1name3,<p1name4,<p1name5,<p1name6,<p1name7,<p1name8,<p1name9,<p1name10 
p1nmhi         !byte >p1name1,>p1name2,>p1name3,>p1name4,>p1name5,>p1name6,>p1name7,>p1name8,>p1name9,>p1name10 
p2hslo         !byte <p2hiscore1,<p2hiscore2,<p2hiscore3,<p2hiscore4,<p2hiscore5,<p2hiscore6,<p2hiscore7,<p2hiscore8,<p2hiscore9,<p2hiscore10
p2hshi         !byte >p2hiscore1,>p2hiscore2,>p2hiscore3,>p2hiscore4,>p2hiscore5,>p2hiscore6,>p2hiscore7,>p2hiscore8,>p2hiscore9,>p2hiscore10
p2nmlo         !byte <p2name1,<p2name2,<p2name3,<p2name4,<p2name5,<p2name6,<p2name7,<p2name8,<p2name9,<p2name10 
p2nmhi         !byte >p2name1,>p2name2,>p2name3,>p2name4,>p2name5,>p2name6,>p2name7,>p2name8,>p2name9,>p2name10 


            
            !ct scr
HiScoreText  
             !text "         congratulations player "
playerno     !text "1       "
             !text "  enter your name for the hall of fame  "
            
