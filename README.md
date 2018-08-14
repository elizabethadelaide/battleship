# battleship
Battleship in MIPS Assembly

Runs in SPIM emulator.

Player plays against a computer, which places random shots against the player. The player can play shots and attempt to sink the enemies battleship.

The game starts with the player setting two large numbers to establish the random seeds. There is a pseudo random number generator that determines the computer's shots.

The player then places their own ships based on the ship size, and direction. The player has ship size 2, 4, 6 and 8, with corrseponding length. The ships can be placed anywhere on the board, and arranged N, E, S or W. The game will check if the ship fits on the board. After placing all the ships, the actual game will start.

The player will call shots with a letter and number, such B4. The shot can be a hit and a miss. A hit on the computer side will be shown as a 2, and a miss will be shown as a 1. The computer will call shots as well. A hit on the player side will increase the player ships number by one (i.e. 2-> 3, 4->5), a miss will be shown as a 1. 

## Sample Board

Ships on the player side are highlighted in green, with the singular hit on the player highlighted in red. The hits on the computer side are highlighted in purple.

[!A battleship board](/images/sampleBoard.jpg)
