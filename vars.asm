; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS
    ORG $80
Frame       ds 1
Rand8       ds 1
plX         ds 1
enX         ds 1
m0X         ds 1
plXL        ds 1
enXL        ds 1
plY         ds 1
enY         ds 1
m0Y         ds 1
plYL        ds 1
enYL        ds 1
plDY        ds 1
enDY        ds 1
m0DY        ds 1    
plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff
plDir       ds 1
enDir       ds 1
enType      ds 1
enStun      ds 1
enRecoil    ds 1
enBlockDir  ds 1
bgColor     ds 1
roomId      ds 1
roomSpr     ds 2
roomDat     ds 20
m0H         ds 1
plState     ds 1
plItemTimer ds 1

	echo "-RAM-",$80,(.)
    
; ****************************************
; * Constants                            *
; ****************************************

ROOM_PX_HEIGHT      = 22 ; height of room in pixels
PLAY_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
GRID_STEP           = 4 ; unit grid that the player should snap to

BoardXL = $10
BoardXR = $8C
BoardYU = $58
BoardYD = $07
EnBoardXR = $80
EnBoardXL = $18
EnBoardYD = $0C
EnBoardYU = $54

ItemTimerSword = -9 ; counts up to 0

PlState_ItemButtonRepeat = $80
PlState_ItemButton = $40
PlState_Stab = $20