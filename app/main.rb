def tick(args)
	init(args) unless args.state.ready == true
	game_step(args)
	update_display(args)
end

def init(args)
	args.state.production = {}
	args.state.production[:ore] = 0
	args.state.inventory = {}	
	args.state.inventory[:ore] = 20
	args.state.buildings = {}
	args.state.buildings[:mine] = 0
	
	prepare_ui(args)
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
end

def prepare_ui(args)
	args.state.ui[:ore] = [300, 300, "Ore: #{args.state.inventory[:ore]}"]
	args.outputs.static_labels << args.state.ui[:ore]
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

def update_display(args)
	args.state.ui[:ore][2] = "Ore: #{args.state.inventory[:ore]}"
end

def make_button(x, y, w, h, text, function, target, args=$gtk.args)
	
	
end