-- pnGallery
-- v0.0.2
-- by @tapecanvas
-- a gallery script for png screenshots
-- companion to norns-canvas
-- 
-- k3: select an image directory (default: /dust/data/norns-canvas/png)
-- e2: change gallery
-- e3: change image
-- 
-- todo:
-- option to hide display info
-- save settings/galleries as params so psets work
-- add option to delete images
-- 
-- done:

local fileselect = require('fileselect')
local tabutil = require('tabutil')
local util = require('util')
local ui = require('ui')
local selected_directories = {} -- table to store the selected directory for each bundle
local tabs = {}
local counts = {} -- table to store the count for each directory
local bundle = {}
local id = 1

function init()
    selected_directory = "/home/we/dust/data/norns-canvas/png/" -- default directory
      selected_directories[id] = selected_directory
      tabs[id] = util.scandir(selected_directory) -- scan the selected directory
      counts[id] = tabutil.count(tabs[id])
      bundle[id] = ui.Pages.new(1,counts[id])
    if not util.file_exists(selected_directory) then
      os.execute("sudo mkdir " .. selected_directory) -- create the default directory if it doesn't exist
      selected_directories[id] = selected_directory
      tabs[id] = util.scandir(selected_directory) -- scan the selected directory
      counts[id] = tabutil.count(tabs[id])
      bundle[id] = ui.Pages.new(1,counts[id])
  end
end

function on_directory_selected(path)
  if path ~= "cancel" then
    id = id+1 -- increment the id to create a new bundle
    local split_at = string.match(path, "^.*()/")
    selected_directory = string.sub(path,1, split_at) -- only use the parent directory of the fileselect choice
    selected_directories[id] = selected_directory 
    tabs[id] = util.scandir(selected_directory) -- scan the selected directory
    counts[id] = tabutil.count(tabs[id])
    bundle[id] = ui.Pages.new(1,counts[id]) -- create a new ui.Pages instance after updating count
    redraw()
  end
end

function redraw()
  screen.clear()
  bundle[id]:redraw() --draw the scrollbar
  screen.font_size(8)
  screen.blend_mode(1) -- 1 XOR: clears any overlapping pixels.
  screen.move(124,10)
  screen.text_right(bundle[id].index.."/"..counts[id]) --draw the current index and total count
  screen.move(0,10)
  screen.text(string.char(id+96)) --print the bundle number - and change the number to alpha char +96(1=a) +64(1=A)
--  screen.move(0,62)
--  screen.text(tabs[id][bundle[id].index]) -- print the currently displayed file name

  local index = bundle[id].index -- get the current index of the bundle
  if bundle[id].index then -- check if there is a file at this index
    png_file = selected_directories[id] .. tostring(tabs[id][index]) -- set png_file based on the current index
    if png_file and #tabs[id] > 0 then -- if a png exists in the selected directory
    screen.display_png(png_file,0,0)
    screen.update()
    else -- if no png exists in the selected directory
      screen.clear()
      screen.font_size(12)
      screen.font_face(21)
      screen.move(64,15)
      screen.font_size(12)
      screen.text_center("-no .png found-")
      screen.level(1)
      screen.text_center_rotate (68, 23, "-dnuof gnp. on-", 180)
      screen.font_size(12)
      screen.move(0,45)
      screen.text("k3: select an")
      screen.move(0, 60)
      screen.text("image directory")
      screen.update()
    end
  end
  screen.update()
end

function enc(n,d)
  if n == 2 then --e2 change bundle - if available
    id = util.clamp(id+d,1,#bundle)
    screen.update()
  elseif n == 3 then --e3 change pages in current bundle
    bundle[id]:set_index_delta(d,false)
  end
  redraw()
end

function key(n, z)
  if n == 3 and z == 1 then
    -- open the fileselect menu
    fileselect.enter(_path.data, on_directory_selected) 
  end
end
