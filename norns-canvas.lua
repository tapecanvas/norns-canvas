-- norns-canvas
-- v0.0.2
-- by @tapecanvas
-- pixel art for norns
-- e2: move cursor x
-- e3: move cursor y
-- k2: place pixels
-- k3: remove pixels
-- k3+k2: take screenshot
-- k1+k3: clear screen
-- screenshots are saved in /dust/data/norns-canvas

-- initialize cursor position
cursor = { x = 64, y = 32 }
-- table to store the drawn pixels
local pixels = {}

local draw_clock_id = nil
-- add a relax variable
local relax = true
local relax_clock_id = nil
local redraw_clock_id = nil
local fn = os.date("%y.%m.%d_%H.%M.%S")

-- screenshot
function take_screenshot()
  fn = os.date("%y.%m.%d_%H.%M.%S")
  _norns.screen_export_png("/home/we/dust/data/norns-canvas/" .. fn .. ".png") -- small transparent screenshot
  -- screen.export_screenshot(fn) -- big screenshot

  -- draw screenshot effect,
  screen.level(15)
  screen.move(64, 32)   -- move to the center of the screen
  screen.circle(64, 32, 30)
  screen.update()
  redraw()
end

-- this is a terrible way to do this -- but i'm struggling to find a better alternative
-- redraws the screen at 1/n sec no matter what.
-- update, now when no activity is happening (relaxed state) no redraw occurs
-- currently getting ~350px until i see screen Q full warnings
function redraw_clock()
  while true do
    if relax then
      clock.cancel(redraw_clock_id)
      redraw_clock_id = nil
      return
    end

    redraw()
    clock.sleep(1 / 30) -- screen refresh at n frames per second
  end
end

function redraw()
  -- clear the screen
  screen.clear()

  -- draw all pixels
  for key, pixel in pairs(pixels) do
    screen.level(15)
    screen.pixel(pixel.x, pixel.y)
    screen.fill()
  end

  -- draw the cursor
  screen.level(3)
  screen.pixel(cursor.x, cursor.y)
  screen.fill()

  -- file, pixel, and cursor info display
  screen.level(15)
  screen.font_face(68)
  screen.font_size(8)
  screen.move(77, 62)
  screen.text("p" .. get_map_size(pixels))
  screen.move(98, 62)
  screen.text("x" .. cursor.x)
  screen.move(115, 62)
  screen.text("y" .. cursor.y)

  -- Update the screen
  screen.update()
end

function get_map_size(map)
  local count = 0
  for _ in pairs(map) do count = count + 1 end
  return count
end

function enc(n, delta)
  -- there is activity, so set relax to false
  relax = false

  -- encoder 2 changes the x position
  if n == 2 then
    cursor.x = util.clamp(cursor.x + delta, 0, 127)
  end

  -- encoder 3 changes the y position
  if n == 3 then
    cursor.y = util.clamp(cursor.y + delta, 0, 55)
  end

  -- start the redraw loop if it's not already running and an encoder was turned
  if (n == 2 or n == 3) and not redraw_clock_id then
    redraw_clock_id = clock.run(redraw_clock)
  end

  -- reset the relax clock
  if relax_clock_id then
    clock.cancel(relax_clock_id)
  end
  relax_clock_id = clock.run(function()
    clock.sleep(0.5) -- wait for 1 second of inactivity
    relax = true
  end)
end

-- create a function to handle common logic of key press
function handle_key_press(key_pressed, clock_id, action)
  if key_pressed then
    if not clock_id then
      clock_id = clock.run(function()
        while key_pressed do
          action()
          clock.sleep(1 / 100) -- place pixels at n times per second
        end
      end)
    end
  else
    if clock_id then
      clock.cancel(clock_id)
      clock_id = nil
    end
  end
  return clock_id
end

-- keys
function key(n, z)
  relax = false

  if n == 1 then
    key1_pressed = z == 1

    if key1_pressed and key3_pressed then
      -- both k1 and k3 are down, so clear the screen
      screen.clear()
      pixels = {} -- clear the pixels table
      screen.update()
    end
  elseif n == 2 then
    key2_pressed = z == 1

    draw_clock_id = handle_key_press(key2_pressed, draw_clock_id, function()
      local pixel = { x = cursor.x, y = cursor.y }
      local key = pixel.x .. ',' .. pixel.y
      if not pixels[key] then
        pixels[key] = pixel
      end
    end)

    -- if both keys are pressed, take screenshot --
    if key2_pressed and key3_pressed then
      take_screenshot()
    end
  elseif n == 3 then
    key3_pressed = z == 1

    remove_clock_id = handle_key_press(key3_pressed, remove_clock_id, function()
      local key = cursor.x .. ',' .. cursor.y
      if pixels[key] then
        pixels[key] = nil
      end
    end)
  end

  -- reset the relax clock
  if relax_clock_id then
    clock.cancel(relax_clock_id)
  end
  relax_clock_id = clock.run(function()
    clock.sleep(.5) -- wait for 1 second of inactivity
    relax = true
  end)

  -- start the redraw loop if it's not already running and a key was pressed
  if z == 1 and not redraw_clock_id then
    redraw_clock_id = clock.run(redraw_clock)
  end
end
