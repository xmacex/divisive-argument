-- divisive argument
--    for just friends
--
-- crow:
--  input 1 = select
--  input 2 = set value
-- jf:
--  argument
--
-- by xmacex

DEBUG = false

function log(s)
   if DEBUG then print(s) end
end

screen.width = 128
screen.height = 64

MINV = -5
MAXV = 10

voice = 1
param = "num"
-- defaults according to Just Type doc
voices = {
   {num=1, den=1},
   {num=2, den=1},
   {num=3, den=1},
   {num=4, den=1},
   {num=5, den=1},
   {num=6, den=1}
}

-- lifecycle stuff

function init()
   init_params()
   screen.aa(1)
   crow.ii.jf.retune(0, 0, 0)
   init_crow()
   ui_metro = metro.new(redraw, 1)
end

function init_params()
   params:add_number('factor', "factor", MAXV, 128, MAXV)
end

function init_crow()
   crow.input[1].window = select_param
   crow.input[1].mode( 'window', {
			  MINV/#voices*5,
			  MINV/#voices*4,
			  MINV/#voices*3,
			  MINV/#voices*2,
			  MINV/#voices,
			  0,
			  MAXV/#voices,
			  MAXV/#voices*2,
			  MAXV/#voices*3,
			  MAXV/#voices*4,
			  MAXV/#voices*5,
		     })

   crow.input[2].stream = retune_jf
   crow.input[2].mode = 'stream'
end

function cleanup()
   crow.ii.jf.retune(0,0,0)
end

--- actual work stuff

function select_param(w)
   p = w-6
   if p <= 0 then
      voice = math.abs(p-1)
      param = "den"
   else
      voice = p
      param = "num"
   end
   -- log(voice.." "..param)
end

function retune_jf(volts)
   local value          = math.abs(math.ceil(volts))
   local value_factored = math.abs(util.linlin(0, 10, 0, params:get('factor'), volts))
   if param == "num" then
      voices[voice].num = value
      crow.ii.jf.retune(voice, value_factored, voices[voice].den)
   elseif param == "den" then
      voices[voice].den = value
      -- log(voice.. " "..param.." ("..volts.."/"..value.."/"..value_factored..")")
      crow.ii.jf.retune(voice, voices[voice].num, value_factored)
   end
end

--- UI stuff

function refresh()
   redraw()
end

function redraw()
   screen.clear()
   draw_graphics()
   screen.update()
end

function draw_graphics()
   for i=1,6 do
      draw_voice(i)
   end
end

function draw_voice(i)
   local vwidth = 12
   local vheight = screen.height*0.7
   local gap = 1
   local hoffset = 10
   local voffset = 10

   -- bar
   if voice == i then
      screen.level(16)
   else
      screen.level(3)
      screen.level(1)
   end
   screen.rect(hoffset+i*(vwidth+gap), voffset, vwidth, vheight)
   screen.fill()

   -- numerator
   -- max value seems retune(c, nominator=127, d)
   screen.circle(hoffset+i*(vwidth+gap)+vwidth/2, 10, vwidth/2)
   screen.level(voices[i].num)
   screen.fill()
   screen.level(voices[i].num)
   if voice == i and param == "num" then
      screen.level(0)
      screen.circle(hoffset+i*(vwidth+gap)+vwidth/2, 10, vwidth/6)
      screen.fill()
   end

   -- denominator
   -- max value seems retune(c, n, denominator=127)
   screen.circle(hoffset+i*(vwidth+gap)+vwidth/2, voffset+vheight, vwidth/2)
   screen.level(voices[i].den)
   screen.fill()
   screen.level(voices[i].den)
   if voice == i and param == "den" then
      screen.level(0)
      screen.circle(hoffset+i*(vwidth+gap)+vwidth/2, voffset+vheight, vwidth/6)
      screen.fill()
   end
end

function enc(n, d)
   if n == 1 then
      params:delta('factor', d)
   end
end
