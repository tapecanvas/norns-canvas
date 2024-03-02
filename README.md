# norns-canvas
 WIP - pixel art for norns

![screenshot](screenshot.png)

## controls:
- v0.0.2
- e2: move cursor x
- e3: move cursor y
- k2: place pixels (press/hold)
- k3: remove pixels (press/hold)
- k3+k2: take screenshot 
- k1+k3: clear screen
- screenshots are saved in /dust/data/norns-canvas

## to-do:
- [ ] optimize drawing (try to prevent as many "warning: screen event Q full!" errors/glitches)
- [ ] extend (these may not be possible)
  - [ ] copy/paste
  - [ ] keyboard control (3 keys are not enough) 
  - [ ] inport png / collage
  - (started) another script idea -> a gallery to display canvas screenshots (see galleryXY.lua)
  - [ ] audio output / input (hmmm...)
- [ ] param to purge /data/norns-canvas/ screenshot folder
- [ ] make screenshot type/size a param option (see screenshot docs)

## archive
- 2d array for pixels
- remove filename display
- started gallery script
- change screenshot to non-upscaled -> [norns screenshot docs](https://monome.org/docs/norns/help/data/#png)
- add wip screenshot
- k1+k3 clear screen
- multiple delete
- update date+time after a screenshot is taken
- date+time screenshot filename
- screenshot function
- add pixel count
- visible cursor
- single/multiple draw
