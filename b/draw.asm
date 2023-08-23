;==============================================================================
; mzxrules 2021
;==============================================================================
;==============================================================================
; Pre-Position Sprites
;==============================================================================
POSITION_SPRITES: SUBROUTINE

; room draw start
    ldy KernelId
    lda .RoomWorldOff,y
    sta roomDY
    tay

    INCLUDE "c/draw_world_init.asm"

;==============================================================================
; HUD Draw Setup
;==============================================================================

.minimap_setup
; map color and sprite id
    ldy worldId
    ldx .MapFlagAddr,y
    lda #$00,x
    and .MapFlagMask,y
    beq .setMinimapColor
    lda #COLOR_MINIMAP
.setMinimapColor
    sta COLUP1

; compass point
    lda WorldCompassRoom,y
    lsr
    lsr
    lsr
    lsr
    tax
    lda .MapDotENA,x
    sta THudMapCPosY

; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    adc Mul8,y
    sta THudMapSpr
    lda #>(MINIMAP)
    sta THudMapSpr+1
; double width map if on overworld
    ldx #5
    lda worldId
    beq .minimap_16
    ldx #$00
.minimap_16
    stx NUSIZ1 ; double minimap size if world 0
    lda #0
    sta COLUBK
    sta NUSIZ0 ; clean sword from previous frame

.hud_sprite_setup
; rupee display
    lda itemRupees
    and #$F0
    lsr ;clc
    adc #7
    sta THudDigits+4
    lda itemRupees
    and #$0F
    rol
    rol
    rol ;clc
    adc #7
    sta THudDigits+5

; bomb display
.hud_bomb_init
    lda itemBombs
    and #$0F
    rol
    rol
    rol ;clc
    adc #7
    sta THudDigits+1
    lda itemBombs
    cmp #$10
    bpl .hud_bomb_digit
    lda #<SprN11_L - #<SprN0_L +7
    .byte $2C
.hud_bomb_digit
    lda #<SprN1_L - #<SprN0_L +7
    sta THudDigits+0

; key display
.hud_key_init
    ldx itemKeys
    bmi .hud_all_keys
    cpx #9
    bmi .hud_key_digit
    ldx #9
    .byte $2C
.hud_all_keys
    ldx #10
.hud_key_digit
    lda Mul8,x
    clc
    adc #7
    sta THudDigits+3
    lda #<SprN10_L - #<SprN0_L +7
    sta THudDigits+2

.PRE_HUD:
    lda roomId
    lsr
    lsr
    lsr
    lsr
    and #$7
    tax
    lda .MapDotENA,x
    sta THudMapPosY

    ldx #1
.hpBarLoop
    lda plHealthMax,x ; Load HP
    clc
    adc #7
    lsr
    lsr
    lsr
    ; divide by 8, rounding up
    tay
    lda .HealthPattern,y
    sta THudHealthMaxL,x
    cpy #8
    bpl .hpBarLoopCont
    ldy #8
.hpBarLoopCont
    lda .HealthPattern-8,y
    sta THudHealthMaxH,x
    dex
    bpl .hpBarLoop

    lda #COLOR_HEALTH
    sta COLUPF

    lda #SLOT_SPR_HU
    sta BANK_SLOT

;===================================================
; Kernel Main
;===================================================
KERNEL_MAIN:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK

KERNEL_HUD:
    lda #%00000101 ; ball size 1, reflect playfield, pf priority
    sta CTRLPF

    ldy #7 ; Draw Height
    lda #0
    beq KERNEL_HUD_LOOP
;=========== Scanline 1A ==============
; 66
.hudScanline1A
    lda THudMapPosY
    lsr
    ror THudMapPosY

    ;sta WSYNC
    lda #0
    stx COLUP0          ; 2
    sta GRP0
    sta PF1
.hudShiftDigitLoop

    ldx THudDigits+2
    stx THudDigits+4

    ldx THudDigits+3
    stx THudDigits+5

    lda THudDigits+1
    sta THudDigits+3

    lda THudDigits+0
    sta THudDigits+2

    lda THudHealthL
    sta THudHealthH
    lda THudHealthMaxL
    sta THudHealthDisp
    dey

    lda THudMapCPosY
    lsr
    ror THudMapCPosY

    lda #0
    sta THudHealthL
    sta THudHealthMaxL
KERNEL_HUD_LOOP:

    sta WSYNC
;=========== Scanline 0 ==============
    sta PF1             ; 3
    lda THudMapPosY     ; 3
    sta ENAM0           ; 3
    lda THudMapCPosY    ; 3
    sta ENABL           ; 3
    lda (THudMapSpr),y  ; 5
    sta GRP1            ; 3

    ldx THudDigits+5    ; 3
    lda SprN0_R,x       ; 4
    ldx THudDigits+4    ; 3
    ora SprN0_L,x       ; 4

    sta GRP0            ; 3
    lda #COLOR_WHITE    ; 2
    sta COLUP0          ; 3
    lda THudHealthDisp  ; 3
    sta PF1             ; 3
    ldx #COLOR_PLAYER_00; 2
    lda THudHealthH     ; 3
    sta THudHealthDisp  ; 3
    lda .HUD_SPLIT_TEST,y ; 4*
    bne .hudScanline1A  ; 2/3
    stx COLUP0          ; 2
    ldx #0              ; 2
; 70
    lda THudMapPosY     ; 3
    lsr
    ;sta WSYNC           ; 3
;=========== Scanline 1 ==============
    stx PF1             ; 3
    ldx THudDigits+5    ; 3
    lda SprN0_R-1,x     ; 4
    dex                 ; 2
    dex                 ; 2
    stx THudDigits+5    ; 3
    ldx THudDigits+4    ; 3
    ora SprN0_L-1,x     ; 4
    dex
    dex
    stx THudDigits+4    ; 3

    sta GRP0            ; 3
    lda THudHealthDisp  ; 3
    sta PF1             ; 3
    lda #COLOR_WHITE    ; 2
    sta COLUP0          ; 3 47

    ror THudMapPosY

    lda THudMapCPosY    ; 3
    lsr
    ror THudMapCPosY

    lda #COLOR_PLAYER_00
    sta COLUP0

    lda #0
    dey
;=========== Scanline 0 ==============
    bpl KERNEL_HUD_LOOP
    sta WSYNC
; HUD LOOP End
    lda #85
    sta TIM8T ; Delay 8 scanlines
    lda #0
    sta ENAM0
    sta GRP1
    sta ENABL

    lda #COLOR_WHITE
    sta COLUP0

    ldx THudDigits+5    ; 3
    lda SprN0_R,x       ; 4
    ldx THudDigits+4    ; 3
    ora SprN0_L,x       ; 4
    sta GRP0            ; 3

    ldx #0
    ldy #COLOR_PLAYER_00

    lda #%00110001 ; ball size 1, reflect playfield, pf priority
    sta CTRLPF

    lda rFgColor
    sta COLUPF

    stx GRP0
    stx GRP1
    sty COLUP0
    LOG_SIZE "-HUD KERNEL-", KERNEL_HUD
    lda KernelId
    beq .defaultWorldKernel
    lda #SLOT_TX
    sta BANK_SLOT
    jmp TextKernel

.defaultWorldKernel
; HMOVE setup
    jsr PosWorldObjects

.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    sta WSYNC

    ldy #ROOM_HEIGHT
KERNEL_WORLD_RESUME:

    lda #$FF
    sta PF0
    sta PF1
    sta PF2
    lda #1
    sta VDELP0

    jsr rKERNEL ; JUMP WORLD KERNEL

; Post Kernel
    lda rFgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP1
    sta GRP0
    sta ENAM0
    sta ENAM1
    sta PF0
    rts
    LOG_SIZE "-KERNEL MAIN-", KERNEL_MAIN
    align $20
    INCLUDE "c/draw_data.asm"

.MapFlagAddr
    .byte #$FF, #$FF
    .byte #<itemMaps, #<itemMaps, #<itemMaps, #<itemMaps

.MapFlagMask
    .byte #$FF, #$FF
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80

.MapDotENA
    .byte 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x01