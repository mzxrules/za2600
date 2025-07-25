;==============================================================================
; mzxrules 2025
;==============================================================================
; Multi-Sprite Boss Prototype

    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
plX         ds 1
enX         ds 1 ; en sprite X pos
m0X         ds 1
m1X         ds 1
blX         ds 1

plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
blY         ds 1

plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff, priority
enSpr2      ds 2 ; enSprOff, secondary
plMSpr      ds 2
enMSpr      ds 2

enBossX     ds 1 ; real boss X pos
enBossY     ds 1


plColor     ds 1
enColor     ds 1

plItemTimer ds 1
plDir       ds 1
plItemDir   ds 1
NUSIZ0_T    ds 1
wM0H        ds 1
plState     ds 1
INPT_FIRE_PREV  = $80 ; 1000_0000 Fire Pressed Last Frame
PS_USE_ITEM     = $40 ; 0100_0000 Use Current Item Event
PS_GLIDE        = $20 ; 0010_0000 Move Until Unblocked
PS_LOCK_MOVE_EN = $10 ; 0001_0000 Lock Player Movement
PS_P1_WALL      = $08 ; 0000_1000 P1 Is Wall
PS_PF_IGNORE    = $04 ; 0000_0100 Playfield Ignore
PS_LOCK_ALL     = $02 ; 0000_0010 Lock Player
PS_LOCK_AXIS    = $01 ; 0000_0001 Lock Player Axis - Hover Boots

ganonKernel ds 1


rPLSPR_MEM = $F400
wPLSPR_MEM = $F600

    echo "-RAM-",$80,(.)