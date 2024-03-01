-- norns-canvas
-- v0.0.1
-- by @tapecanvas
-- pixel art for norns
-- e2: move cursor x
-- e3: move cursor y
-- k2: place pixels
-- k3: remove pixels
-- k3+k2: take screenshot
-- k1+k3: clear screen


-- init position of the cursor
local x = 64
local y = 32

-- table to store the pixels
local pixels = {}

-- table to store the pixels that need to be redrawn
local dirty_pixels = {}

-- table to store the removed pixels
local removed_pixels = {}

local draw_clock_id = nil
local redraw_clock_id = nil
local fn = os.date("%y.%m.%d_%H.%M.%S")


-- screenshot
function take_screenshot()
  screen.export_screenshot(fn)
  -- run the code to show and clear the message in a separate clock
  clock.run(function()
    -- draw a message on the screen
    screen.level(15)
    screen.move(64, 32) -- move to the center of the screen
    screen.circle(64, 32, 80)
    screen.update()
    clock.sleep(.5)
    fn = os.date("%y-%m-%d_%H_%M_%S")
    redraw()
  end)
end

function redraw_clock()
  while true do
    redraw()
    clock.sleep(1 / 10) -- frames per second
  end
end

function redraw()
  -- clear the screen
  screen.clear()

  -- draw the pixels
  for _, pixel in ipairs(pixels) do
    screen.level(15) -- use level 15 to draw the pixel
    screen.pixel(pixel.x, pixel.y)
    screen.fill()
  end

  -- remove the dirty pixels
  for i, pixel in ipairs(dirty_pixels) do
    -- remove the pixel from the dirty_pixels table
    table.remove(dirty_pixels, i)
  end

  -- clear the removed pixels
  for _, pixel in ipairs(removed_pixels) do
    screen.level(0) -- use level 0 to clear the pixel
    screen.pixel(pixel.x, pixel.y)
    screen.fill()
  end
  removed_pixels = {} -- clear the removed_pixels table after the pixels have been cleared

  -- draw the cursor
  screen.level(3)
  screen.pixel(cursor.x, cursor.y)
  screen.fill()

  -- file, pixel, and cursor info display
  screen.level(15)
  screen.font_face(68)
  screen.font_size(8)
  screen.move(0, 62)
  screen.text(fn)
  screen.move(81, 62)
  screen.text("p" .. #pixels)
  screen.move(98, 62)
  screen.text("x" .. cursor.x)
  screen.move(115, 62)
  screen.text("y" .. cursor.y)

  -- Update the screen
  screen.update()
end

-- initialize cursor position
cursor = { x = 64, y = 32 }


function enc(n, delta)
  -- encoder 2 changes the x position
  if n == 2 then
    cursor.x = util.clamp(cursor.x + delta, 0, 127)
  end

  -- encoder 3 changes the y position
  if n == 3 then
    cursor.y = util.clamp(cursor.y + delta, 0, 55)
  end

  -- start the redraw loop if it's not already running
  if not redraw_clock_id then
    redraw_clock_id = clock.run(redraw_clock)
  end
end

function key(n, z)
  if n == 1 then
    k1_down = z == 1
  elseif n == 3 then
    key3_pressed = z == 1

    if key3_pressed and k1_down then
      -- Both k1 and k3 are down, so clear the screen
      screen.clear()
      pixels = {} -- clear the pixels table
      redraw()
    else
      if key3_pressed then
        for i, pixel in ipairs(pixels) do
          if pixel.x == cursor.x and pixel.y == cursor.y then
            table.remove(pixels, i)
            table.insert(removed_pixels, pixel) -- add the removed pixel to the removed_pixels table
            break
          end
        end
      end
    end
  end
  if n == 2 then
    key2_pressed = z == 1

    -- if both keys are pressed, take screenshot
    if key2_pressed and key3_pressed then
      take_screenshot()
    end

    if not redraw_clock_id then
      redraw_clock_id = clock.run(redraw_clock)
    end

    -- k2 startdrawing
    if z == 1 then
      -- k2 pressed
      key2_pressed = true
      -- start a timer to check if key 2 is held
      if key2_pressed then
        -- k2 is held down, start drawing continuously
        draw_clock_id = clock.run(function()
          while key2_pressed do
            local pixel = { x = cursor.x, y = cursor.y }
            -- check if the pixel already exists in the pixels table
            local exists = false
            for _, existing_pixel in ipairs(pixels) do
              if existing_pixel.x == pixel.x and existing_pixel.y == pixel.y then
                exists = true
                break
              end
            end
            -- if the pixel does not exist, add it to the pixels table and the dirty_pixels table
            if not exists then
              table.insert(pixels, pixel)
              table.insert(dirty_pixels, pixel)
            end
            clock.sleep(1 / 30)   -- draw 30 pixels per second
          end
        end)
      end
    else
      -- k2 released
      key2_pressed = false
      if draw_clock_id then
        -- stop drawing continuously
        clock.cancel(draw_clock_id)
        draw_clock_id = nil
      end
    end
  else
    if key3_pressed then
      -- start a timer to check if key 3 is held
      if not remove_clock_id then
        -- k3 is held down, start removing continuously
        remove_clock_id = clock.run(function()
          while key3_pressed do
            for i, pixel in ipairs(pixels) do
              if pixel.x == cursor.x and pixel.y == cursor.y then
                table.remove(pixels, i)
                table.insert(removed_pixels, pixel)   -- add the removed pixel to the removed_pixels table
                break
              end
            end
            clock.sleep(1 / 30)   -- remove 30 pixels per second
          end
        end)
      end
    else
      -- k3 released
      key3_pressed = false
      if remove_clock_id then
        -- stop removing continuously
        clock.cancel(remove_clock_id)
        remove_clock_id = nil
      end
    end
  end
end
