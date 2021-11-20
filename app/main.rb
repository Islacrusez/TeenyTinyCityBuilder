def tick(args)
	init(args) unless args.state.ready == true
	game_step(args)
	update_display(args)
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click
end

def init(args)
	args.state.production = {}
	args.state.production[:ore] = 0
	args.state.inventory = {}	
	args.state.inventory[:ore] = 20
	args.state.buildings = {}
	args.state.buildings[:mine] = 0
	
	args.state.buttons = []
	args.state.buttons << make_button(600, 300, 80, 40, "Build", :build_mine, :mine_button, args)
	args.state.buttons << make_button(600, 400, 80, 40, "Mine", :get_ore, :ore_button, args)
	
	prepare_ui(args)
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
end

def prepare_ui(args)
	args.state.ui[:ore] = [300, 300, "Ore: #{args.state.inventory[:ore]}"]
	args.outputs.static_labels << args.state.ui[:ore]
	args.outputs.static_sprites << args.state.buttons
end

def game_step(args)
	return unless args.tick_count.mod(60) == 0
	args.state.production.each do |resource, amount|
		args.state.inventory[resource] += amount
	end
end

def build_mine(args)
	return if args.state.inventory[:ore] < 20
	args.state.inventory[:ore] -= 20
	args.state.buildings[:mine] += 1
	args.state.production[:ore] += 5	
end

def get_ore(args)
	args.state.inventory[:ore] += 1
end

def update_display(args)
	args.state.ui[:ore][2] = "Ore: #{args.state.inventory[:ore]}"
end

def make_button(x, y, w, h, text, function, target, args=$gtk.args)
	text_w, text_h = $gtk.calcstringbox(text)
	args.render_target(target).height = h
	args.render_target(target).width = w
	out_x = x
	out_y = y
	x = 0
	y = 0
	args.render_target(target).borders << [x, y, w, h]
	args.render_target(target).borders << [x, y+1, w-1, h-1]
	args.render_target(target).borders << [x+2, y+2, w-4, h-4]
	args.render_target(target).labels << [x + (w - text_w) / 2, y + (h + text_h) / 2 - 1, text]
	{x: out_x, y: out_y, w: w, h: h, path: target, function: method(function)}
end

def check_mouse(mouse, args)
	args.state.buttons.each do |button|
		if mouse.inside_rect?(button)
			button[:function].call(args)
			return
		end
	end
end