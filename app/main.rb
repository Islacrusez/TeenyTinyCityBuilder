def tick(args)
	init(args) unless args.state.ready == true
	game_step(args)
	update_display(args)
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click
end

def init(args)
	args.state.production = Hash.new(0)
	args.state.inventory = Hash.new(0)	
	args.state.buildings = Hash.new(0)
	
	args.state.blueprints.structures = {}
	args.state.blueprints.structures[:iron_mine] =
		{	name:		"Iron Ore Mine",
			cost:		{wood: 20},
			production:	{ore: 5}
		}
	args.state.blueprints.structures[:woodcutter] =
		{	name:		"Woodcutter",
			cost:		{wood: 0},
			production:	{wood: 10}
		}
		
	
	args.state.buttons = []
	args.state.buttons << make_button(600, 300, 120, 40, "Build Mine", :build, :iron_mine, :mine_button, args)
	args.state.buttons << make_button(600, 400, 180, 40, "Build Woodcutter", :build, :woodcutter, :woodcutter_button, args)

	
	prepare_ui(args)
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
end

def prepare_ui(args)
	#args.state.ui[:ore] = [300, 300, "Ore: #{args.state.inventory[:ore]}"]
	args.outputs.static_labels << args.state.ui[:ore]
	args.outputs.static_sprites << args.state.buttons

	args.outputs.static_sprites << make_ui_box(:resources_ui, "Resources", 200, 660, args).merge({x: 1060, y: 20})
	#args.outputs.static_sprites << make_ui_box(:production_ui, "Production", 200, 660, args).merge({x: 1060, y: 20})
	
end

def prepare_resource_counters(args)
	row = 0
	args.state.inventory.each do |resource, stock|
		args.state.ui[resource] = [1080, 650 - row*30, "#{resource} : #{args.state.inventory[resource]} (#{args.state.production[resource]})"]
		args.outputs.labels << args.state.ui[resource]
		row += 1
	end
end

def game_step(args)
	return unless args.tick_count.mod(60) == 0
	args.state.production.each do |resource, amount|
		args.state.inventory[resource] += amount
	end
end

def build(building, args=$gtk.args)
	structure = args.state.blueprints.structures[building]
	structure[:cost].each do |material, price|
		return if args.state.inventory[material] < price
	end
	structure[:cost].each do |material, price|
		args.state.inventory[material] -= price
	end
	structure[:production].each do |material, gain|
		args.state.production[material] += gain
	end
end

def update_display(args)
	#args.state.ui[:ore][2] = "Ore: #{args.state.inventory[:ore]}"
	prepare_resource_counters(args)
end

def make_button(x, y, w, h, text, function, arguments, target, args=$gtk.args)
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
	{x: out_x, y: out_y, w: w, h: h, path: target, arguments: arguments, function: method(function)}
end

def check_mouse(mouse, args)
	args.state.buttons.each do |button|
		if mouse.inside_rect?(button)
			button[:function].call(button[:arguments], args)
			return # ends method, use break if further execution is desired
		end
	end
end

def make_ui_box(target, name, w, h, args)
	text_width, text_height = *($gtk.calcstringbox(*name))
	args.outputs[target].primitives << [0, 0, 1280, 720, *$gtk.background_color].solids	
	args.outputs[target].primitives << [0, 0, w, h, 0, 0, 0].borders
	args.outputs[target].primitives << [10, h - text_height / 2, text_width + 10, text_height, *$gtk.background_color].solids
	text, size, font = *name
	args.outputs[target].primitives << [15, h + text_height / 2, text, size, 0, 0, 0, 0, 255, font].labels
	args.outputs[target].height = h + text_height / 2
	args.outputs[target].width = w
	{w: w, h: h + text_height / 2, path: target}
end