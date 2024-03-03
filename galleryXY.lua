-- PngGalleryXY
-- simple png viewer for norns
-- with xy positioning
-- v0.0.1
-- by @tapecanvas

local fileselect = require 'fileselect'
-- images should be stored in data. starting in /dust just makes it easier to understand where you are
local folder_path = 'none'
local png_file = nil
local  cursor = {0,0}

function init()
  screen.aa(0)
  fileselect.enter(_path.data, png_selected)
  cursor = { x = 0, y = 0 }
end

function redraw()
  screen.clear()
  if png_file then
    screen.display_png(png_file, cursor.x, cursor.y)
    else
    screen.level(15)
    screen.move(17,30)
    screen.font_size(12)
    screen.text("gallery closed")
    screen.move(15,45)
    screen.text("for renovation")
  end
  screen.update()
end

function png_selected(file)
  if file ~= "cancel" then
    png_file = file
    screen.update()
    redraw()
  end
  
end

-- k3 opens the file select dialog
function key(n, z)
  if n == 3 and z == 1 then
    fileselect.enter("/home/we/dust/data/norns-canvas/", png_selected)
    cursor={x=0,y=0} -- reset xy position 
  end
end

-- e2 controls x axis of image
function enc(n, delta)
  if n == 2 then
    cursor.x = util.clamp(cursor.x + delta, -127, 127)
    redraw()
  end

-- e3 controls y axis of image
  if n == 3 then
    cursor.y = util.clamp(cursor.y + delta, -64, 64)
  redraw()
  end
end