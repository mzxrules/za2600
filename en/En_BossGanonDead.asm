;==============================================================================
; mzxrules 2025
;==============================================================================

En_BossGanonDead: SUBROUTINE
    bit enState
    bpl .end
    lda #2
    sta wRoomColorFlags

    lda #$0
    sta enState
    rts

.end
    jmp EnSys_KillEnemyA