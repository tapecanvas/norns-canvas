-- PngGalleryXY
-- simple png viewer for norns
-- with xy positioning
-- v0.0.1
-- by @tapecanvas

local fileselect = require 'fileselect'
-- images should be stored in data. starting in /dust just makes it easier to understand where you are
local folder_path = _path.dust
local png_file = nil

function init()
  screen.aa(0)
  fileselect.enter(folder_path, png_selected)
  cursor = { x = 0, y = 0 }
end

function redraw()
  screen.clear()
  if png_file then
    screen.display_png(png_file, cursor.x, cursor.y)
  end
  screen.update()
end

function png_selected(file)
  if file ~= "cancel" then
    png_file = file
    redraw()
  end
end

-- k3 opens the file select dialog
function key(n, z)
  if n == 3 and z == 1 then
    fileselect.enter(folder_path, png_selected)
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
