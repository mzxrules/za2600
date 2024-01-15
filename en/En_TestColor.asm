;==============================================================================
; mzxrules 2024
;==============================================================================
En_TestColor: SUBROUTINE
    lda #1
    and enNum
    beq .continue
    rts

.continue
; init stuff
    lda roomFlags
    ora #RF_PF_IGNORE
    sta roomFlags

    lda #EN_TEST_COLOR
    sta enType+1

    lda #$00
    sta wPF2Room + 4
    sta wPF2Room + 5
    lda #$C0
    sta wPF2Room + 9
    sta wPF2Room + 10
    sta wPF2Room + 11
    sta wPF2Room + 12

    ldy enTestColorBoard
    lda Test_OverworldPatterns,y
    sta Temp0
    and #$0F
    tay
    lda Test_WorldColors,y
    sta wFgColor
    lda Temp0
    lsr
    lsr
    lsr
    lsr
    tay
    lda Test_WorldColors,y
    sta wBgColor

    ldy enTestColorEn
    sty itemRupees
    lda Test_EnColors,y
    sta enTestColorEnColor

; set sprite pos
    ldy #$40
    sty en0X
    sty en1X

    clc
    lda Frame
    lsr
    and #$F
    adc #$30
    tay
    sty en0Y
    sty en1Y

    bit Frame
    bmi .no_en_flicker
.en_flicker
    ldy #$28
    sty en0X
.no_en_flicker

    inc enTestColorPlColor
    lda enTestColorPlColor
    cmp #$C0
    bne .skipPlColor
    lda #0
    sta enTestColorPlColor
    clc
    bit ITEMV_RING_BLUE
    bmi .setPlColor
    bvs .setPlColor
    sec
.setPlColor
    lda ITEMV_RING_BLUE
    ror
    sta ITEMV_RING_BLUE


.skipPlColor

    bit plState
    bvc .rts

    ldy enTestColorEn
    iny
    sty enTestColorEn
    cpy #TEST_COLOR_EN_COUNT
    bne .rts

    ldy #0
    sty enTestColorEn



    ldy enTestColorBoard
    iny
    cpy #TEST_COLOR_BOARD_COUNT
    bne .endNextStep
    ldy #0

.endNextStep
    sty enTestColorBoard

.rts
    rts

Test_PlayerColors:
    .byte #COLOR_PLAYER_00
    .byte #COLOR_PLAYER_01
    .byte #COLOR_PLAYER_02

Test_EnColors:
    .byte #COLOR_EN_RED
    .byte #COLOR_EN_RED_L
    .byte #COLOR_EN_GREEN
    .byte #COLOR_EN_BLUE
    .byte #COLOR_EN_BLUE_L
    .byte #COLOR_EN_YELLOW
    .byte #COLOR_EN_YELLOW_L
    .byte #COLOR_EN_BLACK
    .byte #COLOR_EN_GRAY_D
    .byte #COLOR_EN_GRAY_L
    .byte #COLOR_EN_WHITE
TEST_COLOR_EN_COUNT = . - Test_EnColors

Test_WorldColors:
    /* 00 */ .byte COLOR_PF_BLACK
    /* 01 */ .byte COLOR_PF_GRAY_D
    /* 02 */ .byte COLOR_PF_GRAY_L
    /* 03 */ .byte COLOR_PF_BLUE_D
    /* 04 */ .byte COLOR_PF_BLUE_L
    /* 05 */ .byte COLOR_PF_WATER
    /* 06 */ .byte COLOR_PF_TEAL_D
    /* 07 */ .byte COLOR_PF_PURPLE_D
    /* 08 */ .byte COLOR_PF_PURPLE
    /* 09 */ .byte COLOR_PF_GREEN
    /* 0A */ .byte COLOR_PF_TEAL_L
    /* 0B */ .byte COLOR_PF_CHOCOLATE
    /* 0C */ .byte COLOR_PF_RED
    /* 0D */ .byte COLOR_PF_PATH
    /* 0E */ .byte COLOR_PF_SACRED
    /* 0F */ .byte COLOR_PF_WHITE

Test_OverworldPatterns:
    .byte #$12
    .byte #$1F
/*
    .byte #$D1
    .byte #$D3
    .byte #$D4
    .byte #$D9
    .byte #$DA
*/
    .byte #$DB
    .byte #$DC

Test_DungeonPatterns:
    .byte #$34
    .byte #$43
    .byte #$6A
    .byte #$A6
    .byte #$74
    .byte #$78
    .byte #$AF
    .byte #$1F

Test_DungeonSpecial:
    .byte #$75
    .byte #$6C
    .byte #$7C
    .byte #$A5
    .byte #$15
    .byte #$0C

TEST_COLOR_BOARD_COUNT = . - Test_OverworldPatterns