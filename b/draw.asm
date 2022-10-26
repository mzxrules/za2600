;==============================================================================
; mzxrules 2021
;==============================================================================
    
HUD_SPLIT_TEST:
    .byte 0, 0, 1, 0, 0, 1, 0 ;, 0
    
HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 

;==============================================================================
; Pre-Position Sprites
;==============================================================================
POSITION_SPRITES:

; room draw start
    ldy KernelId
    lda RoomWorldOff,y
    sta roomDY
    
; player draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc plY
    sta plDY

; player missile draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc m0Y
    sta m0DY

.player_sprite_setup
    ldx plDir
    bit plState2
    bpl .loadSprP ; #PS_HOLD_ITEM
    ldx #4
.loadSprP
    lda plSpriteL,x
    sec
    sbc plY
    sta plSpr

    lda #>(SprP0 + 7)
    sta plSpr+1

; enemy draw height
    lda Spr8WorldOff,y
    sec
    sbc enY
    sta enDY

.enemy_sprite_setup
    lda enSpr       ; #<(SprE0 + 7)
    clc
    adc #7
    sec
    sbc enY
    sta enSpr

    lda enSpr + 1   ; #>(SprE0 + 7)
    sbc #0
    sta enSpr + 1
    
.enemy_missile_setup
    lda Spr8WorldOff,y
    sec
    sbc m1Y
    sta m1DY
    
.ball_sprite_setup
; ball draw height
    lda Spr8WorldOff,y
    sec
    sbc blY
    sta blDY
    
.minimap_setup
; map color and sprite id
    ldx worldId
    ldy #COLOR_MINIMAP
    cpx #2
    bmi .setMinimapColor
    lda Bit8-2,x
    and itemMaps
    bne .setMinimapColor
    ldy #0
.setMinimapColor
    sty COLUP1

; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    adc Mul8,x
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
    
    ;lda BANK-ROM + 0
    lda #SLOT_SPR_A
    sta BANK_SLOT

.hud_sprite_setup
; rupee display
    lda itemRupees
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+5
    lda itemRupees
    and #$F0
    lsr
    clc
    adc #7
    sta THudDigits+4

; Triforce display
    lda worldId
    bne .hud_key_init
    bit roomId
    bmi .hud_key_init
    lda itemTri
    lsr
    tax
    lda draw_bitcount,x
    adc #0
    tax
    lda Mul8,x
    clc
    adc #7
    sta THudDigits+3
    lda #<SprN12 - #<SprN0 + 7
    sta THudDigits+2
    bne .hud_bomb_init

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
    lda #<SprN10 - #<SprN0 +7
    sta THudDigits+2

; bomb display
.hud_bomb_init
    lda itemBombs
    cmp #$10
    bpl .hud_bomb_digit
    lda #<SprN11 - #<SprN0 +7
    .byte $2C
.hud_bomb_digit
    lda #<SprN1 - #<SprN0 +7
    sta THudDigits+0 
    lda itemBombs
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+1

    jsr PosHudObjects
;===================================================    
; Pre HUD
;===================================================
.PRE_HUD:
    lda roomId
    lsr
    lsr
    lsr
    lsr
    eor #$7
    and #$7
    sta THudMapPosY

    ldy #1
.hpBarLoop
    lda plHealthMax,y ; Load HP
    clc
    adc #7
    lsr
    lsr
    lsr
    ; divide by 8, rounding up
    tax
    lda HealthPattern,x
    sta THudHealthMaxL,y
    cpx #8
    bpl .hpBarLoopCont
    ldx #8
.hpBarLoopCont
    lda HealthPattern-8,x
    sta THudHealthMaxH,y
    dey
    bpl .hpBarLoop

    lda #COLOR_HEALTH
    sta COLUPF

;===================================================
; Kernel Main
;===================================================
KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK

KERNEL_HUD: SUBROUTINE
    ; precalc digits sprite
    ldx THudDigits+4    ; 3
    lda SprN0,x         ; 4
    and #$F8            ; 2
    sta THudTemp        ; 3

    ldy #7 ; Draw Height
    lda #0
    sta WSYNC
    beq .loop
;=========== Scanline 1A ==============
.hudScanline1A
    lda #0
    sta WSYNC
    stx COLUP0          ; 2
    sta GRP0
    sta PF1
.hudShiftDigitLoop

    ldx THudDigits+2
    stx THudDigits+4

    lda SprN0,x         ; 4
    and #$F8            ; 2
    sta THudTemp        ; 3

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
    lda #0
    sta THudHealthL
    sta THudHealthMaxL
    sta WSYNC
KERNEL_HUD_LOOP:
.loop:

;=========== Scanline 0 ==============
    cpy THudMapPosY     ; 3
    bne .skip           ; 2/3
    lda #2              ; 2
.skip
    sta ENAM0           ; 3
    lda (THudMapSpr),y  ; 5
    sta GRP1            ; 3
    
    ; digit 4 precomputed

    ldx THudDigits+5    ; 3
    lda SprN0,x         ; 4
    and #$07            ; 2
    ora THudTemp        ; 3
    sta GRP0            ; 3
    lda #COLOR_WHITE    ; 2
    sta COLUP0          ; 2
    lda THudHealthDisp
    sta PF1
    ldx #COLOR_PLAYER_00; 2
    lda THudHealthH
    sta THudHealthDisp
    lda HUD_SPLIT_TEST,y
    bne .hudScanline1A
    lda #0
    stx COLUP0          ; 2
    ldx THudDigits+5    ; 3
    sta WSYNC
    sta PF1
;=========== Scanline 1 ==============
    dex                 ; 2
    lda SprN0,x         ; 4
    dex                 ; 2
    stx THudDigits+5    ; 3
    and #$07            ; 2
    sta THudTemp        ; 3 
    ldx THudDigits+4    ; 3
    dex
    lda SprN0,x         ; 4
    and #$F8            ; 2
    ora THudTemp        ; 3
    sta GRP0            ; 3
    lda THudHealthDisp  ; 3
    sta PF1             ; 3
    lda #COLOR_WHITE    ; 2
    sta COLUP0          ; 2
    
    dex
    stx THudDigits+4    ; 3
    lda SprN0,x         ; 4
    and #$F8
    sta THudTemp        ; 3
    lda #COLOR_PLAYER_00
    sta COLUP0

    lda #0
    dey
    sta WSYNC
    sta PF1
;=========== Scanline 0 ==============
    bpl .loop
; HUD LOOP End
    lda #85
    sta TIM8T ; Delay 8 scanlines
    lda #0
    sta ENAM0
    sta GRP1

    lda #COLOR_WHITE
    sta COLUP0
    
    ldx THudDigits+5    ; 3
    lda SprN0,x         ; 4
    and #$07            ; 2
    ora THudTemp        ; 3
    sta GRP0            ; 3
    
    ldx #0
    ldy #COLOR_PLAYER_00
    
    sleep 6
    
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
    
    lda #SLOT_SPR_A
    sta BANK_SLOT

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
    sta PF0
    rts
    LOG_SIZE "-KERNEL MAIN-", KERNEL_MAIN

    .align 64    
;==============================================================================
; PosHudObjects
;----------
; Positions all HUD elements within a single scanline
;----------
; Timing Notes:
; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
;==============================================================================
PosHudObjects: SUBROUTINE
    sta WSYNC
    ; 26 cycles start
    
    lda worldId         ; 3
    ; 7 cycle start
    bne .dungeon        ; 2/3
    lda #$F             ; 2
    bne .roomIdMask     ; 3
.dungeon
    lda #$7             ; 2
    nop                 ; 2
.roomIdMask
    ; 7 cycle end
    
    and roomId          ; 3
    eor #7              ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    sta HMM0            ; 3
    ; 26 cycles end
    sta RESP1           ; 3 - Map Sprite
    sta RESM0           ; 3 - Player Dot
    ; 18 cycles start
    lda worldId         ; 3
    bne .MapShift       ; 2/3
    lda #0              ; 2
    beq .SetMapShift    ; 3
.MapShift
    lda #$F0            ; 2
    nop                 ; 2
.SetMapShift
    sta HMP1            ; 3
    lda #0              ; 2
    sta HMP0            ; 3
    ; 18 cycles end
    sta RESP0           ;  - Inventory Sprites
    
    sta WSYNC
    sta HMOVE
    rts

    .align 8
    
plSpriteL:
    .byte #<(SprP0 + 7), #<(SprP1 + 7), #<(SprP2 + 7), #<(SprP3 + 7)
    .byte #<(SprP4 + 7)

    .align 128
draw_bitcount:
    INCLUDE "gen/bitcount.asm"