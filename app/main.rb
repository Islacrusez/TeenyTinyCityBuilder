require 'app/textbox.rb'
require 'app/blueprints.rb'



	UP = "▲"
	DOWN = "▼"
	RIGHT = "▶"
	LEFT = "◀"
	SIGNS = ["=", "▲", "▼"]
	
	BORDER = {primitive_marker: :border}
	SPRITE = {primitive_marker: :sprite}
	LINE = {primitive_marker: :line}
	LABEL = {primitive_marker: :label}
	SOLID = {primitive_marker: :solid}
	
	FONT = "default"

def tick(args)
	load_structures(args) unless args.state.buildings.ready
	
	args.state.buttons = []
	args.state.production ||= Hash.new(0)
	args.state.consumption ||= Hash.new(0)
	args.state.transactions ||= []
	args.state.inventory ||= Hash.new(0)
	args.state.selection.type ||= :gather
	args.state.selection.mode ||= :split
	args.state.event_log ||= []
	
	add_log("This is a test log, it's short") if args.inputs.keyboard.key_down.one
	add_log("This is a different test log, it's two lines, without room to spare") if args.inputs.keyboard.key_down.two
	add_log("This is a different test log, it's four lines and we can handle many lines more. There is a limit, but this ain't it") if args.inputs.keyboard.key_down.three
	add_log("It's also worth noting that we have highlighting for the most recent message.") if args.inputs.keyboard.key_down.four
	add_log("And it doesn't matter how many lines it is.") if args.inputs.keyboard.key_down.five
	add_log("Oh, and this all works with the expanding box. Looksie!") if args.inputs.keyboard.key_down.six
	add_log("Neat, huh?") if args.inputs.keyboard.key_down.seven
	
	create_resource_objective(:wood, 200, {resource: :workers, amount: 20}, args) if args.inputs.keyboard.key_down.zero
	
	load_scenario(args) unless args.state.scenario.ready


	dialog_box(args.state.selection.building, args)
	
	#args.outputs.borders << args.layout.rect(row: 0, col: 0, w: 6, h: 7) # M1
	args.outputs.borders << args.layout.rect(row: 0, col: 6, w: 12, h: 7) # Viewport
	#args.outputs.borders << args.layout.rect(row: 7, col: 0, w: 6, h: 5) # M2
	#args.outputs.borders << args.layout.rect(row: 0, col: 18, w: 6, h: 12) # Scene Control
	
	## Scene control buttons
	# args.outputs.borders << args.layout.rect(row: 1, col: 19, w: 4, h: 2)
	# args.outputs.borders << args.layout.rect(row: 3, col: 19, w: 4, h: 2)
	# args.outputs.borders << args.layout.rect(row: 5, col: 19, w: 4, h: 2)
	# args.outputs.borders << args.layout.rect(row: 7, col: 19, w: 4, h: 2)
	# args.outputs.borders << args.layout.rect(row: 9, col: 19, w: 4, h: 2)
	
	prepare_resource_text(args)
	box_M1(args)
	box_M2(args)
	scene_control(args.state.selection.mode, args)
	render(args)
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click || args.state.mouse_clicked
	game_step(args)
end

def change_sidebar(current_mode, args)
	mode = case current_mode
		when :split then :log
		when :log then :split
	end
	args.state.selection.mode = mode
end

def scene_control(mode, args)
	unless args.state.sidebar.locations
		args.state.sidebar.locations = {}
		bar = args.state.sidebar.locations
		
		bar[:split] = {
						controls_border: args.layout.rect(row: 0, col: 18, w: 6, h: 7).merge(BORDER),
						log_border: args.layout.rect(row: 7, col: 18, w: 6, h: 5).merge(BORDER),
						blank: args.layout.rect(row: 0.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						overview: args.layout.rect(row: 1.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						city: args.layout.rect(row: 2.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						objectives: args.layout.rect(row: 3.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						trade:	args.layout.rect(row: 4.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						research: args.layout.rect(row: 5.5, col: 18.5, w: 5, h: 1).merge(BORDER),
						change_mode_underlay: args.layout.rect(row: 6.5, col: 19.5, w: 3, h: 1).merge(SOLID).merge({rgb: $gtk.background_color}),
						change_mode: args.layout.rect(row: 6.5, col: 19.5, w: 3, h: 1).merge(BORDER)
						}
		bar[:log] = {
						log_border: args.layout.rect(row: 1, col: 18, w: 6, h: 11).merge(BORDER),
						change_mode: args.layout.rect(row: 0, col: 19.5, w: 3, h: 1).merge(BORDER)
						}
	end
	
	locations_to_use = {}
	
	locations_to_use = case mode
		when :split then args.state.sidebar.locations[:split].values
		when :log then args.state.sidebar.locations[:log].values
	end
	
	display_log(args.state.sidebar.locations[mode][:log_border], args.state.event_log, args)
	
	args.outputs.primitives << locations_to_use
	args.state.buttons << get_button_from_layout(args.state.sidebar.locations[mode][:change_mode], "Toggle Menu", :change_sidebar, mode, :toggle_button, args)
end

def add_log(log_item, args = $gtk.args)
	args.state.event_log.unshift({text: "-----------------------------------------------", size_enum: -4, font: "Default"})
	args.state.log_ui.max_w ||= args.layout.rect(row: 1, col: 18, w: 6, h: 11)[:w]
	puts args.state.log_ui.max_w
	log_item = textbox(log_item, 0, 0, args.state.log_ui.max_w, -2, "default")
	log_item.each{|line| args.state.event_log.unshift({text: line[:text], size_enum: line[:size_enum], font: line[:font]})}
	args.state.last_log_lines = log_item.length
end

def display_log(location, list=$gtk.args.state.event_log, args=$gtk.args)
	x, y = location[:x], location[:y]
	offset_height = y
	lines = []
	hi_lines = args.state.last_log_lines
	hi_h = 0
	list.each do |line|
		offset_y = $gtk.args.gtk.calcstringbox(line[:text], line[:size_enum], line[:font])[1]
		item = {x: x + 5, y: offset_height + 2, text: line[:text], size_enum: line[:size_enum], font: line[:font], vertical_alignment_enum: 0}
		
		hi_h = offset_height - y + (offset_y / 2) if hi_lines == 0
		offset_height += offset_y
		hi_lines -= 1
		
		lines << item.merge(LABEL)
		
		break if (item[:y] + 3 * offset_y) >= (location[:h] + location[:y])
	end
	args.outputs.primitives << {x: x, y: y, w: location[:w], h: hi_h, rgb: [220, 220, 100]}.merge(SOLID)
	args.outputs.primitives << lines
end

def load_scenario(args)
	args.state.objectives = {}
	args.state.starting_inventory = {}
	args.state.starting_transactions = []
	
	args.state.objectives = []

	#args.state.objective_types[:resource_delivery] = "Deliver some resources to complete this objective"
	#args.state.objective_types[:net_production] = "Produce a net gain of this many resources to complete this objective"
	#args.state.objective_types[:structure_built] = "Build this structure to complete this objective"
	
	args.state.starting_inventory[:workers] = 20
	args.state.starting_inventory[:food] = 500
	
	#args.state.starting_transactions << {consumption: {food: 20}}
	
	args.state.starting_inventory.each{|res, amt| gain(res, amt)}
	args.state.starting_transactions.each{|transaction| create_transaction(transaction)}
	
	args.state.scenario.ready = true
end

def create_resource_objective(resource, amount, reward=nil, args=$gtk.args)
	objective = {type: :resource_deliver, check_against: args.state.inventory, resource_type: resource, resource_amount: amount}
	objective[:reward] = reward if reward
	args.state.objectives << objective
	add_log("The King requires a shipment of #{objective[:resource_amount]} #{objective[:resource_type]}!")
end

def objective_met?(objective, args=$gtk.args)
	objective[:resource_amount] <= objective[:check_against][objective[:resource_type]]
end

def eval_objective(objective, args=$gtk.args)
	if objective_met?(objective, args)
		to_log = "You have met the objective to deliver #{objective[:resource_type]}"
		to_log += " and have received #{objective[:reward][:amount]} #{objective[:reward][:resource]}" if objective.has_key?(:reward)
		objective[:completed] = true
		case objective[:type]
			when :resource_deliver
				pay(objective[:resource_type], objective[:resource_amount])
				gain(objective[:reward][:resource], objective[:reward][:amount]) if objective.has_key?(:reward)
			else raise "Invalid objective type"
		end
		add_log(to_log)
	end
end

def prepare_resource_text(args)
	args.state.ui = {}
	return if args.state.inventory.keys.length < 1
	args.state.inventory.each do |resource, stock|
		sign = SIGNS[args.state.production[resource].sign]
		production = i_to_s(args.state.production[resource].abs)
		production = sign + " " + production
		stock = args.state.inventory[resource]
		stock = i_to_s(stock)
		args.state.ui[resource] = "#{stock} (#{production})"
	end
end

def i_to_s(number)
	suffix = ""
	case number
		when 0..10000
		when 10000..10000000
			suffix = " k"
			number = number.idiv(1000)
		else
			suffix = " M"
			number = number.idiv(1000000)
	end
	accumulator = ""
	number = number.to_s.chars
	while number.length > 3
		3.times{accumulator << number.pop}
		accumulator << ","
	end
	number.reverse.each{|digit| accumulator << digit}
	accumulator.reverse+suffix
end

def box_M1(args)
	ui_box = get_ui_box_from_layout(args.layout.rect(row: 0, col: 0, w: 6, h: 7), :m1_build_ui, "Inventory & Production", args)
	
	production = vertical_paired_list({row: 0.75, col: 2, drow: 0.35}, args.state.ui, size=-1, args=$gtk.args)
	args.state.renderables.m1 = []
	args.state.renderables.m1 << ui_box
	args.state.renderables.m1 << production
end

def box_M2(args)
	#args.outputs.borders << args.layout.rect(row: 7, col: 0, w: 6, h: 5) # M2
	buttons = args.state.buttons
	
	buttons << get_button_from_layout(args.layout.rect(row: 7, col: 0, w: 6, h: 1), 
		"Resource Gathering Buildings", :select_type, :gather, :raw_button, args).merge(SPRITE)
	buttons << get_button_from_layout(args.layout.rect(row: 8, col: 0, w: 6, h: 1), 
		"Material Processing Buildings", :select_type, :process, :proc_button, args).merge(SPRITE)
	buttons << get_button_from_layout(args.layout.rect(row: 9, col: 0, w: 6, h: 1), 
		"Special Buildings", :select_type, :upgrade, :prog_button, args).merge(SPRITE)
	buttons << get_button_from_layout(args.layout.rect(row: 11, col: 0, w: 6, h: 1), 
		"Recruit Units", :select_type, :units, :recruit_button, args).merge(SPRITE)
	buttons << get_button_from_layout(args.layout.rect(row: 10, col: 0, w: 6, h: 1), 
		"Demolition", :select_type, :demolish, :demolish_button, args).merge(SPRITE)
end

def select_type(to_select, args)
	args.state.selection.type = to_select
	args.state.selection.building = nil
	args.state.selection.build_page = 0
end

def dialog_box_select_pane(args)
	args.state.dialog_selection_titles ||= {gather: "Construct Gathering Buildings",
											process: "Construct Processing Buildings",
											upgrade: "Construct Advanced Buildings",
											units: "Recruit Units",
											demolish: "Demolish Buildings"}
	dialog_border = args.layout.rect(row: 7, col: 6, w: 12, h: 5).merge(BORDER)
	dialog_ui_line = args.layout.rect(row: 8.5, col: 6.25, w: 11.5, h: 0).merge(BORDER)
	
	details = {}
	details[:name] = args.state.dialog_selection_titles[args.state.selection.type]
	
	title_border = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1).merge(BORDER)
	title_loc = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1)
	title = {x: title_loc[:center_x], y: title_loc[:center_y] - 1, 
							text: details[:name], size_enum: 2,
							vertical_alignment_enum: 1, alignment_enum: 1}.merge(LABEL)
	
	
	### Generate button locations ###
	button_list = []
	borders = button_list
	
	borders << args.layout.rect(row: 8.75, col: 7, w: 4, h: 1)
	borders << args.layout.rect(row: 9.75, col: 7, w: 4, h: 1)
	borders << args.layout.rect(row: 10.75, col: 7, w: 4, h: 1)
	
	borders << args.layout.rect(row: 8.75, col: 11, w: 4, h: 1)	
	borders << args.layout.rect(row: 9.75, col: 11, w: 4, h: 1)
	borders << args.layout.rect(row: 10.75, col: 11, w: 4, h: 1)
	


	### Get and assign building templates ###
	args.state.building_list = Hash.new { |h, k| h[k] = Array.new } # Create a hash, the default value is an empty array
	building_list = args.state.building_list # shorthand
	args.state.blueprints.structures.each do |key, building| # Cycle through all building blueprints
		next unless building[:available] # ignore any that aren't available for construction
		building_list[building[:type]] << key # allocates the building key to the hash, keyed under the building type
	end
	
	args.state.selection.build_page ||= 0
	page = args.state.selection.build_page
	selected_list = building_list[args.state.selection.type].drop(borders.length * page) # drops elements to change page
	
	current = 0
	max = selected_list.length
	
	### Page Buttons ###
	up_button = args.layout.rect(row: 8.75, col: 16.3, w: 1.2, h: 1.5) # UP
	down_button = args.layout.rect(row: 10.25, col: 16.3, w: 1.2, h: 1.5) # DOWN
	page_down = get_button_from_layout(down_button, DOWN, :page_plus, :build_page, :down_button, args) # DOWN
	page_up = get_button_from_layout(up_button, UP, :page_minus, :build_page, :up_button, args) # UP

	args.state.buttons << page_down if max > borders.length
	args.state.buttons << page_up if page > 0
	
	### Assign buildings to buttons ###
	button_list.each do |button_space| # Allocating buttons to buildings, one at a time
		current += 1
		break if current > max # Stop allocating buttons once you run out of buildings
		this_building = selected_list.shift
		name = args.state.blueprints.structures[this_building][:name]
		target = ("build_" + ((this_building).to_s)).to_sym
		this_button = get_button_from_layout(button_space, name, :select_building, this_building, target, args)
		args.state.buttons << this_button
	end
	
	args.state.renderables.dialog = []
	args.state.renderables.dialog << dialog_border
	args.state.renderables.dialog << dialog_ui_line
	args.state.renderables.dialog << title
end

def page_plus(page, args=$gtk.args)
	args.state.selection[page] += 1
end

def page_minus(page, args=$gtk.args)
	args.state.selection[page] -= 1 if args.state.selection[page] - 1 >= 0
end

def dialog_box(building=args.state.selection.building, args=$gtk.args)
	unless building
		dialog_box_select_pane(args)
		return
	end
	structure = args.state.blueprints.structures[building]
	### Overhead ###
	args.state.renderables.dialog = []
	dialog = args.state.renderables.dialog
	details = args.state.blueprints.structures[building]
	
	### Layout ###
	dialog_border = args.layout.rect(row: 7, col: 6, w: 12, h: 5).merge(BORDER)
	dialog_ui_line = args.layout.rect(row: 8.5, col: 6.25, w: 11.5, h: 0).merge(BORDER)
	
	### Back and Build Buttons ###
	buy_button = case args.state.blueprints.structures[building][:type]
		when :units then :recruit
		else :build
	end
	buy_label = buy_button.to_s.capitalize
	back_button = get_button_from_layout(args.layout.rect(row: 7.25, col: 6.5, w: 1, h: 1), LEFT, :select_building, nil, :back_button, args)
	build_button = get_button_from_layout(args.layout.rect(row: 7.25, col: 15.5, w: 2, h: 1), buy_label, buy_button, building, :build_button, args)
	
	args.state.buttons = [build_button.merge(SPRITE), back_button.merge(SPRITE)]

	
	### Title ###
	title_border = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1).merge(BORDER)
	title_loc = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1)
	title = {x: title_loc[:center_x], y: title_loc[:center_y] - 1, 
							text: details[:name], size_enum: 2,
							vertical_alignment_enum: 1, alignment_enum: 1}.merge(LABEL)
	
	### Description ###
	description_loc = args.layout.rect(row: 8.5, col: 6.25, w: 11.5, h: 1)
	description = textbox(details[:description],
						description_loc[:x], description_loc[:center_y], 
						description_loc[:w], 
						size=-2, font=FONT).each{|t| t.merge!({vertical_alignment_enum: 0, primitive_marker: :label})}

	
	### Cost ###
	cost_ui = get_ui_box_from_layout(args.layout.rect(row: 9.5, col: 6.25, w: 3, h: 2.25), :cost_box, "Cost", args).merge(SPRITE)
	cost = vertical_paired_list({row: 10.1, col: 7.75, drow: 0.4}, details[:cost], -2, args) if structure.has_key?(:cost)
	
	### Production / Consumption ###
	prod_ui = get_ui_box_from_layout(args.layout.rect(row: 9.5, col: 9.25, w: 8.5, h: 2.25), :prod_box, "Production and Consumption", args).merge(SPRITE)
	
	if structure.has_key?(:production)
		prod_label_box = args.layout.rect(row: 9.8, col: 9.5, w: 8.5, h: 2.25)
		production_hash = details[:production]
		production_text = horizontal_paired_list("Production: ", production_hash, UP, args)
		production_label = {text: production_text, x: prod_label_box[:x], y: prod_label_box[:center_y], size_enum: -1}.merge(LABEL)
	end
	if structure.has_key?(:consumption)
		con_label_box = args.layout.rect(row: 9.2, col: 9.5, w: 8.5, h: 2.25)
		consumption_hash = details[:consumption]
		consumption_text = horizontal_paired_list("Consumption: ", consumption_hash, DOWN, args)
		consumption_label = {text: consumption_text, x: con_label_box[:x], y: con_label_box[:center_y], size_enum: -1}.merge(LABEL)
	end
	
	### Renderables ###
	dialog << title
	dialog << title_border
	dialog << description	
	dialog << cost_ui
	dialog << cost
	dialog << prod_ui
	dialog << consumption_label	
	dialog << production_label
	dialog << dialog_border
	dialog << dialog_ui_line
end

def render(args)
	args.outputs.primitives << args.state.buttons
	args.outputs.primitives << args.state.renderables.dialog
	args.outputs.primitives << args.state.renderables.m1
end

def horizontal_paired_list(label, hash, symbol=nil, args=$gtk.args)
	add_comma = false
	hash.each do |res, val|
		val = i_to_s(val) if val.is_a?(Integer)
		label += "," if add_comma
		label += sym_to_s(res) + " " + val
		label += symbol if symbol
		add_comma = true
	end
	label
end

def vertical_paired_list(layout, hash, size=0, args=$gtk.args)
	left_array = hash.keys
	right_array = hash.values.map{|val| val.is_a?(Integer) ? i_to_s(val) : val }
	#puts right_array
	
	#right_array.map!{|val| i_to_s(val) if val.is_a?(Integer) }
	#left_array.map!{|val| i_to_s(val) if val.is_a?(Integer) }
	
	left_array.map!{|name| {text: sym_to_s(name)+":", size_enum: size, alignment_enum: 2, primitive_marker: :label}}
	right_array.map!{|val| {text: val.to_s, size_enum: size, alignment_enum: 0, primitive_marker: :label}}

	layout[:drow] ||= 0.5
	
	labels = []
	labels << args.layout.rect_group(layout.merge({group: left_array}))
	labels << args.layout.rect_group(layout.merge({group: right_array}))

	labels
end

def sym_to_s(symbol)
	symbol.capitalize.gsub("_", " ")
end
	
def get_button_from_layout(layout, text, method, argument, target, args)
	make_button(layout[:x], layout[:y], layout[:w], layout[:h], text, method, argument, target, args)
end

def get_ui_box_from_layout(layout, target, text, args)
	make_ui_box(target, text, layout[:w], layout[:h], args).merge({x: layout[:x], y: layout[:y]})
end


def select_building(to_select, args=$gtk.args)
	args.state.selection.building = to_select
end

def game_step(args)
	return unless args.tick_count.mod(60) == 0
	args.state.transactions.each do |transaction|
		costs = transaction[:consumption] if transaction.has_key?(:consumption)
		gains = transaction[:production] if transaction.has_key?(:production)
		transaction_valid = true
		costs.each do |material, value|
			transaction_valid = can_afford?(material, value)
			break unless transaction_valid
		end if transaction.has_key?(:consumption)
		
		if transaction_valid
			costs.each {|material, value| pay(material, value)} if transaction.has_key?(:consumption)
			gains.each {|material, value| gain(material, value)} if transaction.has_key?(:production)
		end
	end
	args.state.objectives.each do |objective| 
		next if objective[:completed]
		eval_objective(objective) 
	end
end

def build(building, args=$gtk.args)
	structure = args.state.blueprints.structures[building]
	
	if structure.has_key?(:cost)
		structure[:cost].each {|material, price| return unless can_afford?(material, price)}
		structure[:cost].each {|material, price| pay(material, price)}
	end
	if structure.has_key?(:unlocks)
		structure[:unlocks].each do |to_unlock|
			args.state.blueprints.structures[to_unlock][:available] = true
		end
	end
	
	create_transaction(structure, args)
end

def recruit(name, args=$gtk.args)
	unit = args.state.blueprints.structures[name]
	
	if unit.has_key?(:cost)
		unit[:cost].each {|material, price| return unless can_afford?(material, price)}
		unit[:cost].each {|material, price| pay(material, price)}
	end
	create_transaction(unit, args)
	gain(name, 1)
end

def can_afford?(item, amount, location=$gtk.args.state.inventory)
	location[item] - amount >= 0
end

def pay(item, amount, location=$gtk.args.state.inventory)
	location[item] -= amount
end

def gain(item, amount, location=$gtk.args.state.inventory)
	location[item] += amount
end

def create_transaction(blueprint, args=$gtk.args)
	transaction = {}
	valid = false
	if blueprint.has_key?(:consumption)
		transaction[:consumption] = blueprint[:consumption]
		transaction[:consumption].each{|material, val| args.state.production[material] -= val}
		valid = true
	end
	if blueprint.has_key?(:production)
		transaction[:production] = blueprint[:production]
		transaction[:production].each{|material, val| args.state.production[material] += val}
		valid = true
	end
	return unless valid
	args.state.transactions << transaction
end

def make_button(x, y, w, h, text, function, arguments, target, args=$gtk.args)
	clicked = (target.to_s+"_clicked").to_sym
	unless args.state.rendered_buttons[target]
		make_clicked_button(w, h, text, clicked, args)
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
	end
	args.state.rendered_buttons ||= {}
	args.state.rendered_buttons[target] = true
	out_x ||= x
	out_y ||= y
	target = clicked if args.state.clicked_button_key == target
	{x: out_x, y: out_y, w: w, h: h, path: target, arguments: arguments, function: method(function)}
end

def make_clicked_button(w, h, text, target, args=$gtk.args)
	text_w, text_h = $gtk.calcstringbox(text)
	args.render_target(target).height = h
	args.render_target(target).width = w
	x = 0
	y = 0
	args.render_target(target).borders << [x, y, w, h]
	args.render_target(target).borders << [x+1, y, w-1, h-1]
	args.render_target(target).borders << [x+2, y+2, w-4, h-4]
	args.render_target(target).labels << [x + (w - text_w) / 2, y + (h + text_h) / 2 - 1, text]
end

def check_mouse(mouse, args)
	args.state.buttons.each do |button|
		if mouse.inside_rect?(button)
			args.state.mouse_clicked = true
			args.state.clicked_button = button
			args.state.clicked_button_key = button[:path]
			break
		end
	end unless args.state.mouse_clicked
	on_button = false
	if mouse.inside_rect?(args.state.clicked_button)
		args.state.clicked_button_key = args.state.clicked_button[:path]
		on_button = true
	end
	args.state.clicked_button_key = false unless on_button
	if mouse.up
		args.state.clicked_button[:function].call(args.state.clicked_button[:arguments], args) if on_button
		args.state.mouse_clicked = false
		args.state.clicked_button = nil
		args.state.clicked_button_key = nil
	end
end

def make_ui_box(target, name, w, h, args)
	text_width, text_height = *($gtk.calcstringbox(*name))
	args.outputs[target].primitives << [0, 0, w, h, *$gtk.background_color].solids	
	args.outputs[target].primitives << [0, 0, w,  h - text_height / 2, 0, 0, 0].borders
	args.outputs[target].primitives << [10, h - text_height, text_width + 10, text_height, *$gtk.background_color].solids
	text, size, font = *name
	args.outputs[target].primitives << [15, h, text, size, 0, 0, 0, 0, 255, font].labels
	args.outputs[target].height = h
	args.outputs[target].width = w
	{w: w, h: h, path: target}
end

def do_nothing(nil_argument = nil, args=$gtk.args)
	# no-op
end
