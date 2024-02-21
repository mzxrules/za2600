;==============================================================================
; mzxrules 2023
;==============================================================================
En_BossGlockHead: SUBROUTINE
    lda enHp
    bne .continue
    sta enType,x
.continue


.bounceTest

    bit enState+1
    bvs .endBounce

    lda en1X
    cmp #EnBoardXL
    beq .bounce
    cmp #EnBoardXR
    beq .bounce
    lda en1Y
    cmp #EnBoardYD
    beq .bounce
    cmp #EnBoardYU
    beq .bounce

.think
    lda enGlockHeadThink
    cmp #1
    adc #0
    sta enGlockHeadThink
    bne .endThink

    jsr Random
    and #7
    sta enGlockHeadDir
    lda Rand16
    and #$1F
    adc #$D8
    sta enGlockHeadThink
    bmi .endThink


.bounce
    ldy enGlockHeadDir
    lda EnMoveBounce,y
    sta enGlockHeadDir
    lda #$40
    sta enState+1
.endBounce
.endThink


.move_logic
    lda Frame
    ror
    bcc .move
    rts

.move
    lda enState+1
    and #~$40
    sta enState+1

    lda enGlockHeadDir
    and #7
    tay
    jmp EnMoveDel
