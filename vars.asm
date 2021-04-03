; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
Rand8       ds 1
plX         ds 1
enX         ds 2
m0X         ds 1
m1X         ds 1
plXL        ds 1
enXL        ds 2
plY         ds 1
enY         ds 2
m0Y         ds 1
m1Y         ds 1
plYL        ds 1
enYL        ds 2
plDY        ds 1
enDY        ds 1
m0DY        ds 1
plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff
plDir       ds 1
enDir       ds 2
enType      ds 2
enColor     ds 2
enBlockDir  ds 1
enStun      ds 1
enRecoil    ds 1

bgColor     ds 1
fgColor     ds 1
worldId     ds 1
roomId      ds 1
roomSpr     ds 1
roomFlags   ds 1
    ; 1000_0000 Force Load Room
roomDoors   ds 1
    ; xxxx_xx11 N
    ; xxxx_11xx S
    ; xx11_xxxx E
    ; 11xx_xxxx W
roomLocks   ds 10
roomItems   ds 6
m0H         ds 1
plState     ds 1
    ; 1000_0000 Fire Pressed Last Frame
    ; 0100_0000 Use Current Item
    ; 0000_1000 Enemy Is Wall
    ; 0000_0100 Playfield Ignore
    ; 0000_0010 Lock Player
    ; 0000_0001 Lock Player Axis
    
enState     ds 1
    
    
plItemTimer ds 1
itemKeys    ds 1
itemBombs   ds 1
itemRupees  ds 1
itemTri     ds 1

mapSpr      ds 2
Temp0       ds 1
Temp1       ds 1
Temp2       ds 1
Temp3       ds 1

	echo "-RAM-",$80,(.)
    
    ORG $F000
WORLD_TILE      ds 256
WORLD_DOOR      ds 256
WORLD_COLOR     ds 256
WORLD_LOCK      ds 16
WORLD_LOCK_FLAG ds 16
KERNEL_SCRIPT   ds (4 * 2)
ROOM_SCRIPT     ds $20 * 2

    ORG $F800
wPF1RoomL   ds ROOM_PX_HEIGHT
wPF2Room    ds ROOM_PX_HEIGHT
wPF1RoomR   ds ROOM_PX_HEIGHT

    ORG $F900
rPF1RoomL   ds ROOM_PX_HEIGHT
rPF2Room    ds ROOM_PX_HEIGHT
rPF1RoomR   ds ROOM_PX_HEIGHT
    
    
; ****************************************
; * Constants                            *
; ****************************************

ROOM_PX_HEIGHT      = 20 ; height of room in pixels
ROOM_SPR_HEIGHT     = 16 ; height of room sprite sheet
ROOM_SPR_SHEET      = 16 ; width of room sprite sheet in 8 bit sprites
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

COLOR_DARKNUT_RED   = $42
COLOR_DARKNUT_BLUE  = $74
COLOR_PATH          = $3C
COLOR_GREEN_ROCK    = $D0
COLOR_CHOCOLATE     = $F0
COLOR_EARTH         = $F2
COLOR_LIGHT_WATER   = $A4
COLOR_LIGHT_BLUE    = $88
COLOR_DARK_BLUE     = $90
COLOR_GOLDEN        = $1E

COLOR_PLAYER_00 = $C6
COLOR_PLAYER_01 = $08
COLOR_PLAYER_02 = $46

COLOR_MINIMAP = $84

    MACRO LOG_SIZE
        echo .- {2}+$8000,{2},(.),{1}
    ENDM