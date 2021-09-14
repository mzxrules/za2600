#!/usr/bin/env python3
import itertools

mesg_table = [
    "MesgGameOver", [
      # "012345678901234567890123",
        "        GAME OVER       ",
        " PRESS FIRE TO CONTINUE ",
        ],
    "MesgNeedTriforce", [
        "  ONES WHO DO NOT HAVE  ",
        "  TRIFORCE CAN'T GO IN  ",
        ],
    "MesgTakeThis", [
        "  IT'S DANGEROUS TO GO  ",
        "   ALONE! TAKE THIS.    ",
        ],
    "MesgMasterSword", [
        "  MASTER USING IT AND   ",
        "   YOU CAN HAVE THIS.   ",
        ],
    # SHOP, must be $10 aligned i think
    "MesgShopCheap", [
        " BUY SOMETHING WILL YA? ",
        "   99      99      99   ", # 34, 12, 9A
        ],
    "MesgShopExpensive", [
        "THIS STUFF SURE IS PRICY",
        "   99      99      99   ", # 34, 12, 9A
        ],
    "MesgPotion", [
        "PLEASE SAVE THE PRINCESS",
        "   99      99      99   ",
        ],
    "MesgChoiceGiveItem", [
        " TAKE ANY ONE YOU WANT  ",
        "   99              99   ",
        ],
    "MesgChoiceTakeItem", [
        "LEAVE YOUR LIFE OR MONEY",
        "  -40             -01   ",
        ],
    "MesgPotion0", [
        "I WILL NOT HELP MINIONS ",
        " OF GANON. LEAVE NOW!   ",
        ],
    "MesgGiveRupees", [
        "     IT'S A SECRET      ",
        "     TO EVERYBODY.      ",
        ],
    "MesgTakeRupees", [
        "PAY ME FOR DOOR REPAIRS.",
        "                        ",
        ],
]

mesg_ids = mesg_table[::2]
mesg_data = list(itertools.chain.from_iterable(mesg_table[1::2]))