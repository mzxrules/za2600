;==============================================================================
; mzxrules 2022
;==============================================================================

;==============================================================================
; World Draw Setup
; Y = World View Height, in PF pixels -1
;==============================================================================
    
; player draw height
    lda Spr8WorldOff,y ;#(ROOM_HEIGHT+8)
    sec
    sbc plY
    sta plDY

; player missile draw height
    lda Spr8WorldOff,y ;#(ROOM_HEIGHT+8)
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