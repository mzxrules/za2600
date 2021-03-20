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
m1X         ds 1
plXL        ds 1
enXL        ds 1
plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
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
enColor     ds 1

bgColor     ds 1
fgColor     ds 1
worldId     ds 1
roomId      ds 1
roomSpr     ds 2
roomDoors   ds 1
roomPFDat   ds 4 * 6
roomLocks   ds 3
roomItems   ds 6
m0H         ds 1
plState     ds 1
plItemTimer ds 1
itemKeys    ds 1
itemBombs   ds 1
itemRupees  ds 1
itemTri     ds 1

	echo "-RAM-",$80,(.)
    
; ****************************************
; * Constants                            *
; ****************************************

ROOM_PX_HEIGHT      = 20 ; height of room in pixels
ROOM_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
GRID_STEP           = 4 ; unit grid that the player should snap to

BoardXL = $0F
BoardXR = $89
BoardYU = $51
BoardYD = $07
EnBoardXR = $80
EnBoardXL = $18
EnBoardYD = $0C
EnBoardYU = $4C

ItemTimerSword = -9 ; counts up to 0

PlState_ItemButtonRepeat = $80
PlState_ItemButton = $40
PlState_Stab = $20

COLOR_DARKNUT_RED = $42
COLOR_DARKNUT_BLUE = $74
COLOR_PATH = $3C
COLOR_LIGHT_WATER = $AE