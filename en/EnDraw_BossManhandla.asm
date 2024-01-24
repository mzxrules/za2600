;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_BossManhandla: SUBROUTINE
    lda Frame
    ror ; carry = frame % 2
    lda enState
    and #$0F
    bcs .renderRight

.renderLeft
    tax
    lda Manhandla_FlagsHeight,x
    rol
    bcc .skipReflectLeft
    ldy #%1000
    sty wREFP1_T
.skipReflectLeft
    and #%11100
    ora #%00011
    bpl .writeHeight ; jmp

.renderRight
    ora #$10
    tax
    lda Manhandla_FlagsHeight-$10,x
    ror
    bcc .skipReflectRight
    ldy #%1000
    sty wREFP1_T
.skipReflectRight
    ror
    and #%11100
    ora #%00011

.writeHeight
    sta wENH

    clc
    lda en0X
    adc ManhandlaL_x,x
    sta enX
    clc
    lda en0Y
    adc ManhandlaL_y,x
    sta enY

    lda ManhandlaL_SprL,x
    sta enSpr+1
    lda ManhandlaL_SprH,x
    sta enSpr

    clc
    lda enManhandlaStun
    asl
    asl
    adc #COLOR_EN_BLUE
    sta wEnColor

    lda #%0101
    sta wNUSIZ1_T
    rts

    INCLUDE "gen/EnDraw_BossManhandlaGen.asm"