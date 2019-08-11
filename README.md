# Skorp2
A multiplayer version of the Motivator that I made a few years ago

This is a 2-player game; each player is a small square, and large rectangles move around on the screen. If you get hit by a rectangle, you are "dead;" the enemy gets a point and the field resets. There is also a death line that will sometimes appear; when this appears the enemy will be unable to move close to the edges and you will be able to move around them. The enemy is restricted so that you can use the death line to kill them. You have to be careful though; because the death line will grow out of a corner of the field towards you, and it can kill you if it reaches you. You can't evade the line by moving because it will always point to you and it grows faster the farther away you go. You have to kill the line by spamming the spacebar until the health bar at the top of the screen is empty.
If you hit the enemy, you both gain a point and the field resets.
At the beginning of every match, there is a 10% chance that a point will be taken away from you (for no reason other than it's funny).

When you first enter a match or the field resets, you have to press enter in order to become "ready." After both players are ready, the server will wait 3 seconds and then start the game.

Problems:
The game uses TCP for multiplayer; the server (whoever is hosting the game) sends the game world to the client on every update. This is extremely inefficient and often causes some considerable lag for the client. Maybe someday I'll fix it.

The Keybinds menu doesn't actually do anything; when I added it I was planning on having keys bound to chat messages that could be sent to the enemy. I got bored though and never finished it.

When you first run the game you have to click the sound button twice in order to actually hear the sound

Sometimes the server never gets the client's ready message, so both players can be ready and the game will never start.

Because there is no central server, whoever is hosting the game will always have 0 latency and the client will always be behind by several milliseconds.
