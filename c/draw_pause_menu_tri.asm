;==============================================================================
; mzxrules 2022
;==============================================================================
DRAW_PAUSE_MENU_TRI: BHA_BANK_FALL #SLOT_F4_PAUSE_DRAW_MENU2
    lda worldId
    bmi .continue_draw_tri
    ldy #17
.line_delay
    sta WSYNC
    dey
    bpl .line_delay
    jmp draw_pause_menu_map

.continue_draw_tri
;==============================================================================
; Initialize Sprite
;==============================================================================

    lda #>tri_0
    sta PItemSpr0+1
    sta PItemSpr1+1
    sta PItemSpr2+1
    sta PItemSpr3+1

    ldy itemTri
; Strip 0
    ldx #<tri_1
    tya ; itemTri
    and #$04
    bne .fill0
    ldx #<tri_0
.fill0
    stx PItemSpr0

; Strip 3
    ldx #<tri_1
    tya ; itemTri
    and #$08
    bne .fill3
    ldx #<tri_0
.fill3
    stx PItemSpr3

; Strip 1
; Convert pattern xx11xxx1 -> 01110000
    tya ; itemTri
    lsr
    tya ; itemTri
    and #$30
    bcc .skipAdd1
    adc #[$40 - 1]
.skipAdd1
    adc #<tri_2
    sta PItemSpr1

; Strip 2
; Convert pattern 11xxxx1x -> 01110000
    tya ; itemTri
    lsr
    lsr
    and #$30
    bcc .skipAdd2
    adc #[$40 - 1]
.skipAdd2
    adc #<tri_2
    sta PItemSpr2

;==============================================================================
; Initialize Sprite Properties
;==============================================================================

    lda #$8
    sta REFP1 ; Enable P1 mirroring

    lda #63
    ldx #0
    jsr PosMenuObject_2
    lda #71
    ldx #1
    jsr PosMenuObject_2
    sta WSYNC
    lda #$01 ; Two copies close for P0 and P1
    sta NUSIZ0
    sta NUSIZ1
    lda #COLOR_EN_TRIFORCE
    sta COLUP0
    sta COLUP1

    sta WSYNC
    sta HMOVE
    ldy #15

.x48
    REPEAT 2 ; Draw each line twice before inc sprite
    sta WSYNC
    lda (PItemSpr0),y   ; 5 (5)
    sta GRP0            ; 3 (8)
    lda (PItemSpr1),y   ; 5 (13)
    sta GRP1            ; 3 (16)
    lda (PItemSpr2),y   ; 5 (21)
    sta GRP0            ; 3 (24)

    lda (PItemSpr3),y   ; 5 (29)

    SLEEP 16            ; MUST HIT 45
    sta GRP1            ; 3 (48)
    sta GRP0            ; 3 (51)
    REPEND

    dey                 ; 2 (53)
    bpl     .x48        ; 2/3 (55-56)

    lda #$00            ; 2 (63)
    sta GRP0            ; 3 (66)
    sta GRP1            ; 3 (69)
    sta GRP0            ; 3 (66)
    sta REFP1 ; Disable P1 mirroring

    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    lda #0
    sta COLUP0
    sta COLUP1
    ldy #82
    jmp draw_pause_finish_frame

;==============================================================================
; Map Draw Test
;==============================================================================
draw_pause_menu_map:
; Reset CTRLPF
    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    lda #0
    sta COLUP0
    sta COLUP1
    INCLUDE "c/draw_pause_menu_map.asm"

;==============================================================================
; Finish Frame
;==============================================================================
    ldy #17
.dummy_end
draw_pause_finish_frame:
    sta WSYNC
    dey
    bne .dummy_end
    rts

    align 256
    INCLUDE "gen/spr_tri.asm"

PosMenuObject_2: SUBROUTINE
    INCLUDE "c/sub_PosObject.asm"