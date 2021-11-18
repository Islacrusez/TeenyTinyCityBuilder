def tick(args)
	init(args) unless args.state.ready == true
	game_step(args)
end

def init(args)
	args.state.production = {}
	args.state.production[:ore] = 0
	args.state.inventory = {}	
	args.state.inventory[:ore] = 20
	args.state.buildings = {}
	args.state.buildings[:mine] = 0
	
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
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