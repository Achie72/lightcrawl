- add f5 and ctrl f5 with shortcut

- MVP STUFF







- Good to have

- RESET VARIABLES
- spawn a weapon first always

- Rewrite spawning
  - Problem comes from movement and spawning intervals
  - always need so spawn something later than the previous moved away
  - look into different step values






- Animations
- Particles

- indiacte differently with particles if shield is damaged or health
- some kind of unique version for HP regain
- Add outlines to texts
- SFX
- Background
- Add legendary items to shops
- Text floats (non mvp)
- Smoother movement (non mvp)
- Enemy vareity (??? very much not MVP feature)
- sprite outlines?
- CHECK WHAT does in gmatch()

- Any button vs designated control button
- Look into touchscreen controls with love.js (!!!!) (not MVP, good to have)
  - Figure out how to detect "touch" vs "hold"
  - Code almost works, but seems to ignore the hold effect

- Figure out if movement is gonna be speed based (so objects always move with speed X) OR we are doing steps which is always 1 pixel, but control how fast steps follow each other

- CONSIDER REPLACING ITEMS WITH BUFFS

- make it so that negative choice cannot be greater than your current value (???)
  - could apply to only health maybe????

- fix gameover logo being even so no middle align

# DONE

- Add UI boxes
- particle variety
- update prices of shops based on difficulty


- Add actual button listener
- smooth movement - probably should move to end goal if another input is sent
- POC rewrite of spawn functions
- add at least slimes back
- fixed scaling
- fixed buffs erroring
- fixed weapon pickup

- Enemy (and all item) scaling
- Money
- Shops (hp, shield, damage, durability upgrades) at every 20 or so spawnss
- small fixes for the morning
  - gold can be spen on 
- Volume Control
- Muisc
- double spawn 
- FIGURE OUT A SCENE STATE MACHINE
- Create pickups (potions, whetstones, hammers) (DONE)
- Create buffs (+1hp, +1durability etc...) for example (-2 hp/+5 shield) (+5 hp/-2 damage) (DONE)
- make it so that a choice is always a choice, aka if you have 0 in a stat, do not roll said stat for a choice item. (DONE)
- Gameover