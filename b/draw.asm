;==============================================================================
; mzxrules 2021
;==============================================================================
    
;==============================================================================
; Pre-Position Sprites
;==============================================================================
POSITION_SPRITES:

; room draw start
    ldy KernelId
    lda RoomWorldOff,y
    sta roomSpr
    
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
    lda #<(SprP0 + 7) ; Sprite + height-1
    clc
    ldx plDir
    adc Mul8,x
    sec
    sbc plY
    sta plSpr

    lda #>(SprP0 + 7)
    sbc #0
    sta plSpr+1

; enemy draw height
    lda Spr8WorldOff,y
    sec
    sbc enY
    sta enDY

.enemy_sprite_setup
    lda enSpr; #<(SprE0 + 7)
    clc
    adc #7;enSpr
    sec
    sbc enY
    sta enSpr

    lda enSpr + 1;#>(SprE0 + 7)
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
    sta mapSpr
    lda #>(MINIMAP)
    sta mapSpr+1
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
    lda #SLOT_SP_A
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
; key display
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
    sta TMapPosY
    lda plHealth
    clc
    adc #7
    lsr
    lsr
    lsr
    sta THudHealthL
    sec
    sbc #8
    bcs .skipHealthHighClampMin
    lda #0
.skipHealthHighClampMin
    tax
    lda HealthPattern,x
    sta THudHealthH
    beq .skipHealthClamp
    lda #8
    sta THudHealthL
.skipHealthClamp
    ldx THudHealthL
    lda HealthPattern,x
    sta THudHealthL
    
    lda #COLOR_PLAYER_02
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
    ldy #7 ; Draw Height
    lda #0
    sta WSYNC
    beq .loop
;=========== Scanline 1A ==============
.hudScanline1A
    ldx #3
    sta WSYNC
    sta GRP0
    sta PF1
.hudShiftDigitLoop
    lda THudDigits,x
    sta THudDigits+2,x
    dex
    bpl .hudShiftDigitLoop
    lda THudHealthL
    sta THudHealthH
    dey
    lda #0
    sta THudHealthL
    nop ;sta WSYNC
KERNEL_HUD_LOOP:
.loop:

;=========== Scanline 0 ==============
    cpy TMapPosY ; 3
    bne .skip ; 2/3
    lda #2    ; 2
.skip
    sta ENAM0 ; 3
    lda (mapSpr),y ; 5
    sta GRP1 ; 3
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    lda #0
    cpy #5
    beq .hudScanline1A
    cpy #2
    beq .hudScanline1A
    sta WSYNC
    sta PF1
;=========== Scanline 1 ==============
    dec THudDigits+4 ; 5
    dec THudDigits+5 ; 5
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    dec THudDigits+4
    dec THudDigits+5
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
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    
    lda rFgColor
    sta COLUPF
    
    ldx #0
    stx GRP0
    stx GRP1
    LOG_SIZE "-HUD KERNEL-", KERNEL_HUD
    lda KernelId
    beq .defaultWorldKernel
    lda #SLOT_TX_A
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
    
    lda #SLOT_SP_A
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

    .align 256    
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