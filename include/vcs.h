;==========================
; Equates for TIA Registers
;==========================
    IFCONST TIA_BASE_ADDRESS
        IF TIA_BASE_ADDRESS != 0
TIA_BASE_ADDRESS    = $40
        ENDIF
    ELSE
TIA_BASE_ADDRESS    = $00
    ENDIF

;----------------------
; Write Address Summary
;----------------------
        SEG.U   TIA_REGISTERS_WRITE
        ORG     TIA_BASE_ADDRESS
VSYNC   ds 1    ;$00     Vertical sync set-clear
VBLANK  ds 1    ;$01     Vertical blank set-clear
WSYNC   ds 1    ;$02     Wait for leading edge of horizontal blank
RSYNC   ds 1    ;$03     Reset horizontal sync counter
NUSIZ0  ds 1    ;$04     Number size Player Missile 0
NUSIZ1  ds 1    ;$05     Number size Player Missile 1
COLUP0  ds 1    ;$06     Color-lum Player 0
COLUP1  ds 1    ;$07     Color-lum Player 1
COLUPF  ds 1    ;$08     Color-lum playfield
COLUBK  ds 1    ;$09     Color-lum background
CTRLPF  ds 1    ;$0A     Ctrol playfield ball size & collisions
REFP0   ds 1    ;$0B     Reflect player #0
REFP1   ds 1    ;$0C     Reflect player #1
PF0     ds 1    ;$0D     First 4 bits of playfield
PF1     ds 1    ;$0E     Middle 8 bits of playfield
PF2     ds 1    ;$0F     Last 8 bits of playfield
RESP0   ds 1    ;$10     Reset player #0 X coord
RESP1   ds 1    ;$11     Reset player #1 X coord
RESM0   ds 1    ;$12     Reset missile #0 X coord
RESM1   ds 1    ;$13     Reset missile #1 X coord
RESBL   ds 1    ;$14     Reset ball
AUDC0   ds 1    ;$15     Audio control 0
AUDC1   ds 1    ;$16     Audio control 1
AUDF0   ds 1    ;$17     Audio frequency 0
AUDF1   ds 1    ;$18     Audio frequency 1
AUDV0   ds 1    ;$19     Audio volume 0
AUDV1   ds 1    ;$1A     Audio volume 1
GRP0    ds 1    ;$1B     Pixel data player #0
GRP1    ds 1    ;$1C     Pixel data player #1
ENAM0   ds 1    ;$1D     Missile 0 enable register
ENAM1   ds 1    ;$1E     Missile 1 enable register
ENABL   ds 1    ;$1F     Ball enable register
HMP0    ds 1    ;$20     Horizontal motion Player #0
HMP1    ds 1    ;$21     Horizontal motion Player #1
HMM0    ds 1    ;$22     Horizontal motion Missile #0
HMM1    ds 1    ;$23     Horizontal motion Missile #1
HMBL    ds 1    ;$24     Horizontal motion Ball
VDELP0  ds 1    ;$25     Vertical delay Player #0
VDELP1  ds 1    ;$26     Vertical delay Player #1
VDELBL  ds 1    ;$27     Vertical delay Ball
RESMP0  ds 1    ;$28     Reset Missle 0 to Player 0
RESMP1  ds 1    ;$29     Reset Missle 1 to Player 1
HMOVE   ds 1    ;$2A     Add horizontal motion to registers
HMCLR   ds 1    ;$2B     Clear horizontal motion registers
CXCLR   ds 1    ;$2C     Clear collision registers

;---------------------
; Read Address Summary
;---------------------
        SEG.U   TIA_REGISTERS_READ
        ORG     TIA_BASE_ADDRESS

CXM0P   ds 1    ;$00     Read collision M0-P1/M0-P0
CXM1P   ds 1    ;$01     Read collision M1-P0/M1-P1
CXP0FB  ds 1    ;$02     Read collision P0-PF/P0-BL
CXP1FB  ds 1    ;$03     Read collision P1-PF/P1-BL
CXM0FB  ds 1    ;$04     Read collision M0-PF/M0-BL
CXM1FB  ds 1    ;$05     Read collision M1-PF/M1-BL
CXBLPF  ds 1    ;$06     Read collision BL-PF/-----
CXPPMM  ds 1    ;$07     Read collision P0-P1/M0-M1
INPT0   ds 1    ;$08     Paddle #0
INPT1   ds 1    ;$09     Paddle #1
INPT2   ds 1    ;$0A     Paddle #2
INPT3   ds 1    ;$0B     Paddle #3
INPT4   ds 1    ;$0C     Misc input #0
INPT5   ds 1    ;$0D     Misc input #1

;======================
; Equates for PIA Ports
;======================
        SEG.U   RIOT
        ORG      $280
SWCHA   ds 1    ;$280    Port A data register for joysticks
SWACNT  ds 1    ;$281    Part A data direction register (DDR)
SWCHB   ds 1    ;$282    Port B data (console switches)
SWBCNT  ds 1    ;$283    Port B data direction register (DDR)
INTIM   ds 1    ;$284    Timer output
TIMINT  ds 1    ;$285    PIA IRQ, Bit 7 is timer
        ORG      $294
TIM1T   ds 1    ;$294    Set 1 clock interval
TIM8T   ds 1    ;$295    Set 8 clock interval
TIM64T  ds 1    ;$296    set 64 clock interval
T1024T  ds 1    ;$297    set 1024 clock interval
        SEG