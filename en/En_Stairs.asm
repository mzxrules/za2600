;==============================================================================
; mzxrules 2024
;==============================================================================
EN_STAIRS_DEFAULT = #0
EN_STAIRS_HIDE_IF_OBSCURED = #1
EN_STAIRS_DISPLAY_ONLY = #2

EnStairs: SUBROUTINE
    lda cdStairType,x
    cmp #EN_STAIRS_HIDE_IF_OBSCURED
    beq EnStairs_Position
    cmp #EN_STAIRS_DISPLAY_ONLY
    beq .rts
    lda en0X,x
    ldy en0Y,x
    cmp plX
    bne .rts
    cpy plY
    bne .rts
    tax
    lda #HALT_TYPE_EXIT_TO_STAIRS
    jmp EXIT_TO_SUBWORLD
.rts
    rts

EnStairs_Position: SUBROUTINE
    ldy cdStairPos,x
    clc
    lda plX
    sbc StairPosX,y
    sbc #8-1
    adc #8+8-1

    bcc .place_stairs

    clc
    lda plY
    sbc StairPosY,y
    sbc #8-1
    adc #8+8-1
    bcs .rts

.place_stairs
    lda StairPosX,y
    sta en0X,x
    lda StairPosY,y
    sta en0Y,x
    lda #EN_STAIRS_DEFAULT
    sta cdStairType,x
.rts
    rts


StairPosX:
    .byte #$40, #$18, #$74, #$74
    .byte #$28
StairBushPosX:
StairDungPosX:
    .byte #$40, #$34, #$40, #$58
    .byte #$64, #$64, #$6C
StairPosY:
    .byte #$2C, #$34, #$48, #$2C
    .byte #$28
StairBushPosY:
StairDungPosY:
    .byte #$1C, #$28, #$2C, #$20
    .byte #$20, #$38, #$18
