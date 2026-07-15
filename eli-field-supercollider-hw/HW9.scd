// HW9 - GUI
// This HW is optional. If completed, I will drop your lowest HW grade.

/*

Recreate a simple game in SuperCollider, adding some sound elements of your own.

Some options:

--------------------

Option 1: Simon

https://en.wikipedia.org/wiki/Simon_(game)

- One-player game of short-term memory, featuring four buttons that are able to "light up" in unique colors. When a button illuminates, it should also produce a unique sound. You can use the Button class for this, but other GUI classes may also work.

- The computer generates a random sequence, represented by timed illumination of buttons. The length of the sequence should initially be four, and each turn the length should increase by one.

- On each turn, the computer plays the current sequence. Then, the user must play back the sequence by pressing (clicking) the buttons.

- The game continues until the user makes a mistake. There should be a unique "game over" sound, and the game should display the user's score (the length of the longest sequence that was correctly reproduced).

- The user should have the ability to restart the game with a new random sequence (other than closing the game window and re-evaluating the code).

--------------------

Option 2: Tic-Tac-Toe

https://en.wikipedia.org/wiki/Tic-tac-toe

- Designed for 2 human players sharing the same computer.

- Featuring a window containing 9 buttons in 3x3 grid, each with 3 states (blank, X, O).

- The game keeps track of whose turn it is. The first clicked button should change to the "X" state, the next clicked button should change to the "O" state. This process should alternate.

- Players should only be able to click blank buttons. Once a button is clicked, it should become un-clickable (disabled but still visible).

- After each click, the game should check for a win. If a win is detected, post "X wins" or "O wins" in the post window. If all buttons are claimed but there is no three-in-a-row, post "draw" in the post window.

- A reset button that resets all buttons to their blank state, re-enables all buttons to be clickable, and makes it X's turn.

- The game should alo produce six unique sounds that accompany these six actions:

- X makes a move
- O makes a move
- X wins
- O wins
- The game is drawn
- The game is reset

--------------------

Option 3: Snake (a bit more challenging)

https://en.wikipedia.org/wiki/Snake_(video_game_genre)

- A dynamic one-player game of maneuvering a line (snake) in cardinal directions (up/down/left/right) to pick up objects (food). Each time the snake consumes a piece of food, the length of the snake increases.

- If the snake collides with itself or a wall, the game ends, and the score (quantity of food consumed) is displayed.

- The game should play a sound whenever food is consumed or the game ends.

--------------------

Option 4: Minesweeper (also challenging)

https://en.wikipedia.org/wiki/Minesweeper_(video_game)

*/