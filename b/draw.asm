;==============================================================================
; mzxrules 2021
;==============================================================================

DRAW_WorldSetup: SUBROUTINE
    INCLUDE "c/draw_world_init.asm"
    rts

DRAW_HudSetup:
.hud_minimap_visible
    ldy worldId
    ldx .MapFlagAddr-#LV_MIN,y
    lda $00,x
    and .MapFlagMask-#LV_MIN,y
    beq .setMinimapColor
    lda #COLOR_MINIMAP
.setMinimapColor
    sta COLUP1


.hud_compass_pos_y
    ldx .CompassFlagAddr-#LV_MIN,y
    lda $00,x
    and .CompassFlagMask-#LV_MIN,y
    beq .setCompassPoint
    lda .MapData_CompassDotENA-#LV_MIN,y
.setCompassPoint
    sta THudMapCPosY


.hud_minimap_sprite
    lda #<[MINIMAP] ; Sprite + height-1
    clc
    adc Mul8-#LV_MIN,y
    sta THudMapSpr
    lda #>[MINIMAP]
    sta THudMapSpr+1
; double width map if on overworld
    ldx #%101
    lda worldId
    bmi .minimap_16
    ldx #%000
.minimap_16
    stx NUSIZ1 ; double minimap size if world 0


.hud_rupee_init
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


.hud_bomb_init
    lda itemBombs
    and #$1F
    tay
    lda .BombCountSprL,y
    sta THudDigits+1
    lda itemBombs
    lda .BombCountSprH,y
    sta THudDigits+0


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


.hud_pl_pos_y:
    lda roomId
    lsr
    lsr
    lsr
    lsr
    and #$7
    tax
    lda .MapDotENA,x
    sta THudMapPosY


.hud_health
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
    lda .HealthPattern+8,y
    sta THudHealthMaxL,x
    lda .HealthPattern,y
    sta THudHealthMaxH,x
    dex
    bpl .hpBarLoop
    rts

DRAW_HUD_WORLD:
;==============================================================================
; World Draw Setup
;==============================================================================

    jsr DRAW_WorldSetupPre
    jsr DRAW_WorldSetup
    lda #0
    sta COLUBK
    sta NUSIZ0 ; clean sword from previous frame

;==============================================================================
; HUD Draw Setup
;==============================================================================

    bit rHudMode
    bvs KERNEL_MAIN_HUD_WORLD
    jsr DRAW_HudSetup

;===================================================
; Kernel Main - HUD and World
;===================================================
KERNEL_MAIN_HUD_WORLD:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN_HUD_WORLD
    sta VBLANK

KERNEL_HUD:
    lda #%00000101 ; ball size 1, reflect playfield, pf priority
    sta CTRLPF

    lda #COLOR_HEALTH
    sta COLUPF

    lda #SLOT_F0_SPR_HUD
    sta BANK_SLOT

    lda #COLOR_PLAYER_00
    sta COLUP0

    bit rHudMode
    bpl .hud_mode_fixed
.hud_mode_slide
    jsr KERNEL_WORLDVIEW_SKIP
.hud_mode_fixed

    bvs .hud_mode_off
    ldy #7 ; Draw Height
    lda #0
    beq KERNEL_HUD_LOOP ; jmp, assume A = 0

.hud_mode_off
    ldy #16
.hud_blackout_loop
    sta WSYNC
    dey
    bne .hud_blackout_loop
    sta WSYNC
; HUD LOOP End
    sleep 24
    ; y = 0
    jmp HUD_BLACKOUT_ENTRY

;=========== Scanline 1A ==============
; cycle 66
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
    iny ; ldy #0
    sty ENAM0
    sty GRP1
    sty ENABL

    ldx THudDigits+5    ; 3
    lda SprN0_R,x       ; 4
    ldx THudDigits+4    ; 3
    ora SprN0_L,x       ; 4
    sta GRP0            ; 3

HUD_BLACKOUT_ENTRY:
; Text kernel prep
    ldx #COLOR_WHITE
    stx COLUP0
    stx COLUP1

    lda #SLOT_F0_TEXT
    sta BANK_SLOT

    ldx #%00110001 ; ball size 8, reflect playfield, pf priority
    stx CTRLPF

    ldx rFgColor
    stx COLUPF

    sleep 3

    sty GRP0
    sty GRP1
    sta WSYNC

    bit rHudMode
    bmi .skip_hud_sliding
    jsr KERNEL_WORLDVIEW_SKIP
.skip_hud_sliding

    LOG_SIZE "-HUD KERNEL-", KERNEL_HUD
    lda rTextMode
    bpl .defaultWorldKernel ; !#TEXT_MODE_ACTIVE
    jmp TextKernel
.defaultWorldKernel

KERNEL_WORLDVIEW_START
    sta WSYNC
    sta WSYNC
KERNEL_WORLD_TX_RETURN
; HMOVE setup
    jsr PosWorldObjects

    ; The miracle scanline?!
    lda rHaltKernelId
    bne .kernel_draw_player ; #HALT_KERNEL_HUD_WORLD_NOPL
    lda #$DC
    sta plDY
    sta m0DY
.kernel_draw_player
    ldy roomDY
    lda .RoomHeight,y
    jmp (rWorldKernelDraw)

KERNEL_WORLD_RESUME:
    sta WSYNC
    tay
    lda #$FF
    sta PF0
    sta PF1
    sta PF2
    lda #1
    sta VDELP0

    jmp rKERNEL_WORLD ; JUMP WORLD KERNEL

KERNEL_WORLDVIEW_BLACK:
    sta WSYNC
    lda #COLOR_BLACK
    sta COLUP0
    sta COLUP1
    sta COLUPF
    sta COLUBK

.kernel_worldview_black_loop
    sta WSYNC
    sta WSYNC
    dey
    bpl .kernel_worldview_black_loop
    sta WSYNC
    rts

KERNEL_WORLDVIEW_SKIP:
    ldx RoomPX
    cpx #ROOM_PX_HEIGHT-1
    bpl .skipVerticalShift
.wsyncLoop
    ldy #7
.wsyncLoop_inner
    sta WSYNC
    dey
    bpl .wsyncLoop_inner
    inx
    cpx #ROOM_PX_HEIGHT-1
    bmi .wsyncLoop
.skipVerticalShift
    rts

    LOG_SIZE "-KERNEL MAIN-", KERNEL_MAIN_HUD_WORLD

    align $20

.HUD_SPLIT_TEST:
    .byte 0, 0, 1, 0, 0, 1, 0 ;, 0

.HealthPattern:
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF

    INCLUDE "c/draw_data.asm"

.MapFlagAddr
    .byte #<ITEMV_MAP_1, #<ITEMV_MAP_1
    .byte #<itemMaps, #<itemMaps, #<itemMaps, #<itemMaps
    .byte #<itemMaps, #<itemMaps, #<itemMaps, #<itemMaps
    .byte #<itemMaps, #<itemMaps, #<itemMaps, #<itemMaps
    .byte #<itemMaps, #<itemMaps, #<itemMaps, #<itemMaps
    .byte #$FF, #$FF

.MapFlagMask
    .byte #ITEMF_MAP_1, #ITEMF_MAP_1
    .byte 0x01, 0x01, 0x02, 0x02, 0x04, 0x04, 0x08, 0x08
    .byte 0x10, 0x10, 0x20, 0x20, 0x40, 0x40, 0x80, 0x80
    .byte #$FF, #$FF

.MapDotENA
    .byte 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x01

.CompassFlagAddr
    .byte #<ITEMV_COMPASS_1, #<ITEMV_COMPASS_1
    .byte #<itemCompass, #<itemCompass, #<itemCompass, #<itemCompass
    .byte #<itemCompass, #<itemCompass, #<itemCompass, #<itemCompass
    .byte #<itemCompass, #<itemCompass, #<itemCompass, #<itemCompass
    .byte #<itemCompass, #<itemCompass, #<itemCompass, #<itemCompass
    .byte #$FF, #$FF

.CompassFlagMask
    .byte #ITEMF_COMPASS_1, #ITEMF_COMPASS_1
    .byte 0x01, 0x01, 0x02, 0x02, 0x04, 0x04, 0x08, 0x08
    .byte 0x10, 0x10, 0x20, 0x20, 0x40, 0x40, 0x80, 0x80
    .byte #0, #0

.MapData_CompassDotENA
    INCLUDE "gen/world/mapdata_compass_dotENA.asm"

.BombCountSprL
    .byte 0*8+7, 1*8+7, 2*8+7, 3*8+7, 4*8+7, 5*8+7, 6*8+7, 7*8+7, 8*8+7, 9*8+7
    .byte 0*8+7, 1*8+7, 2*8+7, 3*8+7, 4*8+7, 5*8+7, 6*8+7

.BombCountSprH
    REPEAT 10
    .byte #<SprN11_L - #<SprN0_L +7
    REPEND
    REPEAT 7
    .byte #<SprN1_L - #<SprN0_L +7
    REPEND

DRAW_WorldSetupPre:
; Room Color
    ldx #0
    bit rRoomColorFlags
    bvs .dark
    lda rRoomColorFlags
    and #$3F
    tax
.dark
    lda WorldColorsFg,x
    sta wFgColor
    lda WorldColorsBg,x
    sta wBgColor

; room draw start
    ldy RoomPX
    lda rTextMode
    bpl .skip_textmode_view ; !#TEXT_MODE_ACTIVE
    cpy #ROOM_PX_HEIGHT-1
    bne .textmode_invalid
    and #$7F
    tay
    lda .RoomWorldOff,y
    tay
.textmode_invalid
.skip_textmode_view

    sty roomDY
    rts