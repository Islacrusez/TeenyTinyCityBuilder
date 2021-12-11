require 'app/textbox.rb'

	UP = "▲"
	DOWN = "▼"
	RIGHT = "▶"
	LEFT = "◀"
	SIGNS = ["=", "▲", "▼"]
	
	BORDER = {primitive_marker: :border}
	SPRITE = {primitive_marker: :sprite}
	LINE = {primitive_marker: :line}
	LABEL = {primitive_marker: :label}
	
	FONT = "default"

def tick(args)
	load_structures(args) unless args.state.buildings.ready
	
	args.state.buttons = []
	args.state.production ||= Hash.new(0)
	args.state.consumption ||= Hash.new(0)
	args.state.transactions ||= []
	args.state.inventory ||= Hash.new(0)
	args.state.selection.type ||= :gather


	dialog_box(args.state.selection.building, args)
	
	#args.outputs.borders << args.layout.rect(row: 0, col: 0, w: 6, h: 7) # M1
	args.outputs.borders << args.layout.rect(row: 0, col: 6, w: 12, h: 7) # Viewport
	#args.outputs.borders << args.layout.rect(row: 7, col: 0, w: 6, h: 5) # M2
	args.outputs.borders << args.layout.rect(row: 0, col: 18, w: 6, h: 12) # Scene Control
	
	## Scene control buttons
	args.outputs.borders << args.layout.rect(row: 1, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 3, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 5, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 7, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 9, col: 19, w: 4, h: 2)
	
	prepare_resource_text(args)
	box_M1(args)
	box_M2(args)
	render(args)
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click || args.state.mouse_clicked
	game_step(args)
end

def prepare_resource_text(args)
	args.state.ui = {}
	return if args.state.inventory.keys.length < 1
	args.state.inventory.each do |resource, stock|
		sign = SIGNS[args.state.production[resource].sign]
		production = sign + " " + args.state.production[resource].abs.to_s
		stock = args.state.inventory[resource]
		case stock
			when 10000000..10000000000 then stock = stock.idiv(1000000).to_s + "M"
			when 10000..10000000 then stock = stock.idiv(1000).to_s + "k"
			when 0..10000
			else
		end
		args.state.ui[resource] = "#{stock} (#{production})"
	end
end

def box_M1(args)
	ui_box = get_ui_box_from_layout(args.layout.rect(row: 0, col: 0, w: 6, h: 7), :m1_build_ui, "Inventory & Production", args)
	
	production = vertical_paired_list({row: 1, col: 2, drow: 0.5}, args.state.ui, size=0, args=$gtk.args)
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
	#args.outputs.primitives << args.state.clicked_button
	
	args.outputs.primitives << args.state.renderables.dialog
	args.outputs.primitives << args.state.renderables.m1
end

def horizontal_paired_list(label, hash, symbol=nil, args=$gtk.args)
	add_comma = false
	hash.each do |res, val|
		label += "," if add_comma
		label += res.to_s.capitalize.gsub("_", " ") + " " + val.to_s
		label += symbol if symbol
		add_comma = true
	end
	label
end

def vertical_paired_list(layout, hash, size=0, args=$gtk.args)
	left_array = hash.keys
	right_array = hash.values
	
	left_array.map!{|name| {text: name.to_s.capitalize.gsub("_", " ")+":", size_enum: size, alignment_enum: 2, primitive_marker: :label}}
	right_array.map!{|val| {text: val.to_s, size_enum: size, alignment_enum: 0, primitive_marker: :label}}

	layout[:drow] ||= 0.5
	
	labels = []
	labels << args.layout.rect_group(layout.merge({group: left_array}))
	labels << args.layout.rect_group(layout.merge({group: right_array}))

	labels
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

def load_structures(args)
	args.state.blueprints.structures = {}
	args.state.blueprints.structures[:iron_mine] =
		{	name:		"Iron Ore Mine",
			cost:		{wood: 30, workers: 3},
			production:	{ore: 10},
			consumption: {wood: 3, food: 3},
			available: true,
			type: :gather,
			description: "Mining tunnels deep into rock, reinforced by wooden beams. Produces iron ore that requires refinement at a smelter."
		}
	args.state.blueprints.structures[:smelter] =
		{	name:		"Smelter",
			cost:		{stone: 60, wood: 20, workers: 2},
			production:	{iron: 2},
			consumption: {coal: 10, ore: 10},
			available: true,
			type: :process,
			description: "A tall chimney furnace able to smelt iron ore into somewhat usable metal"
		}
	args.state.blueprints.structures[:woodcutter] =
		{	name:		"Woodcutter's Hut",
			production:	{wood: 20},
			available: true,
			type: :gather,
			description: "Shelter for woodcutter and tools, produces wood for construction"
		}

	args.state.blueprints.structures[:quarry] =
		{	name:		"Quarry",
			cost:		{wood: 40},
			production:	{stone: 10},
			available: true,
			type: :gather,
			description: "Scaffolding across a rockface where usable stone is cut from the cliff"
		}
	args.state.blueprints.structures[:charcoal_pile] =
		{	name:		"Charcoal Pile",
			cost:		{wood: 100},
			production:	{coal: 2},
			consumption: {wood: 20},
			available: true,
			type: :process,
			description: "A pile of wood covered in earth and sealed so as to burn down into charcoal. An inefficient way to gain coal-type fuel."
		}
	args.state.blueprints.structures[:blacksmith] =
		{	name:		"Blacksmith",
			cost:		{wood: 30, stone: 100, iron: 50},
			production:	{tools: 5},
			consumption: {iron: 10, coal: 20},
			available: true,
			type: :process,
			description: "A furnace and anvil, where a craftsman hammers iron bars into wrought-iron tools."
		}
	args.state.blueprints.structures[:farm] =
		{	name:		"Farm",
			cost:		{wood: 30},
			production:	{food: 10},
			available: true,
			type: :gather,
			description: "A farm that produces food."
		}
	args.state.blueprints.structures[:coal_mine] =
		{	name:		"Coal Mine",
			cost:		{wood: 30, workers: 6},
			production:	{coal: 20},
			consumption: {wood: 3, food: 3},
			available: true,
			type: :gather,
			description: "A mine yielding coal"
		}
	args.state.blueprints.structures[:fishing_wharf] =
		{	name:		"Fishing Wharf",
			cost:		{wood: 30, workers: 10, stone: 100, boats: 2},
			production:	{food: 20},
			consumption: {wood: 3, rope: 3},
			available: true,
			type: :gather,
			description: "A stone quay where fishing boats can be docked and unloaded"
		}
	args.state.blueprints.structures[:grain_farm] =
		{	name:		"Grain Farm",
			production:	{grain: 20},
			available: true,
			type: :gather,
			description: "A farm that produces grain for animal feed and to grind into flour"
		}
	args.state.blueprints.structures[:workers] =
		{	name:		"Worker",
			cost:		{food: 50},
			consumption: {food: 1},
			available: true,
			type: :units,
			description: "A peasant, able to work the land and gather resources"	
		}
		
	args.state.buildings.ready = true
	$gtk.notify!("Buildings loaded!")
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
end

def build(building, args=$gtk.args)
	structure = args.state.blueprints.structures[building]
	
	if structure.has_key?(:cost)
		structure[:cost].each {|material, price| return unless can_afford?(material, price)}
		structure[:cost].each {|material, price| pay(material, price)}
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
		make_clicked_button(x, y, w, h, text, clicked, args)
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

def make_clicked_button(x, y, w, h, text, target, args=$gtk.args)
	text_w, text_h = $gtk.calcstringbox(text)
	args.render_target(target).height = h
	args.render_target(target).width = w
	x = 0
	y = 0
	args.render_target(target).borders << [x, y, w, h]
	args.render_target(target).borders << [x+1, y, w-1, h-1]
	args.render_target(target).borders << [x+2, y+2, w-4, h-4]
	args.render_target(target).labels << [x + (w - text_w) / 2, y + (h + text_h) / 2 - 1, text]
	#{clicked_path: target}
end

def check_mouse(mouse, args)
	args.state.buttons.each do |button|
		if mouse.inside_rect?(button)
			args.state.mouse_clicked = true
			args.state.clicked_button = button
			args.state.clicked_button_key = button[:path]
			#button[:function].call(button[:arguments], args)
			break # ends method, use break if further execution is desired
		end
	end unless args.state.mouse_clicked
	on_button = false
	if mouse.inside_rect?(args.state.clicked_button)
		#args.state.clicked_button[:path] = (args.state.clicked_button[:path].to_s+"_clicked").to_sym unless args.state.clicked_button_updated
		#args.state.clicked_button_updated = true
		
		#puts args.state.clicked_button[:path]
		#args.outputs.sprites << args.state.clicked_button
		args.state.clicked_button_key = args.state.clicked_button[:path]
		on_button = true
	end
	args.state.clicked_button_key = false unless on_button
	if mouse.up
		args.state.clicked_button[:function].call(args.state.clicked_button[:arguments], args) if on_button
		args.state.mouse_clicked = false
		args.state.clicked_button = nil
		#args.state.clicked_button_updated = nil
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