-- pnGallery
-- v0.0.1
-- by @tapecanvas
-- scandir + util-pages
-- working towards a gallery script for png screenshots

local tabutil = require('tabutil')
local util = require('util')
local ui = require('ui')
local tab = {}
local bundle = {}
local id = 1

function init()
  tab = util.scandir("/home/we/dust/data/norns-canvas/") -- where screenshots from norns-canvas are saved
  count = tabutil.count(tab)
  bundle[1] = ui.Pages.new(1,count)
  --bundle[2] = ui.Pages.new(1,count) -- if you wanted to add another folder of images (would need a rework of scandir/tab etc, but its possible)
end

function redraw()
  screen.clear()
  bundle[id]:redraw() --draw the scrollbar
  --screen.move(10,10)
  --screen.text("bundle "..id) --draw the bundle number
  screen.move(128,10)
  screen.text_right(bundle[id].index.."/"..count) --draw the current index and total count

  local index = bundle[id].index -- get the current index of the bundle
  if bundle[id].index then -- check if there is a file at this index
    png_file = "/home/we/dust/data/norns-canvas/" .. tostring(tab[index]) -- set png_file based on the current index
    screen.display_png(png_file,0,0)
    screen.update()
  end
  --screen.move(0,62)
  --screen.text(tostring(tab[index])) -- display file name bottom left
  screen.update()
end

function enc(n,d)
  if n == 2 then --e2 change bundle
    id = util.clamp(id+d,1,#bundle)
  elseif n == 3 then --e3 change pages in current bundle
    bundle[id]:set_index_delta(d,false)
  end
  redraw()
end
