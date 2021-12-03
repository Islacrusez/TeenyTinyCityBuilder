# def tick(args)
	# init(args) unless args.state.ready == true
	# game_step(args)
	# update_display(args)
	# check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click
# end

	UP = "▲"
	DOWN = "▼"
	RIGHT = "▶"
	LEFT = "◀"

def tick(args)
	args.state.production ||= Hash.new(0)
	args.state.inventory ||= Hash.new(0)

	args.state.selection.building ||= :iron_mine
	args.state.blueprints.structures = {}
	args.state.blueprints.structures[:iron_mine] =
		{	name:		"Iron Ore Mine",
			cost:		{wood: 30, workers: 3},
			production:	{ore: 1},
			consumption: {wood: 3, tools: 1},
			available: false,
			description: "Mining tunnels deep into rock, reinforced by wooden beams. Produces iron ore that requires refinement at a smelter."
		}
	args.state.blueprints.structures[:smelter] =
		{	name:		"Smelter",
			cost:		{stone: 60, wood: 20, workers: 2},
			production:	{iron: 1},
			consumption: {coal: 10, iron_ore: 10},
			available: false,
			description: "A tall chimney furnace able to smelt iron ore into somewhat usable metal"
		}

	dialog_box(args.state.selection.building, args)# if args.state.selection.building
	
	check_mouse(args.inputs.mouse, args) if args.inputs.mouse.click
	
	args.outputs.borders << args.layout.rect(row: 0, col: 0, w: 6, h: 7) # M1
	args.outputs.borders << args.layout.rect(row: 0, col: 6, w: 12, h: 7) # Viewport
	args.outputs.borders << args.layout.rect(row: 7, col: 0, w: 6, h: 5) # M2
	args.outputs.borders << args.layout.rect(row: 0, col: 18, w: 6, h: 12) # Scene Control
	
	## Scene control buttons
	args.outputs.borders << args.layout.rect(row: 1, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 3, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 5, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 7, col: 19, w: 4, h: 2)
	args.outputs.borders << args.layout.rect(row: 9, col: 19, w: 4, h: 2)
	
	render(args)
end

def dialog_box(building=args.state.selection.building, args=$gtk.args)
	raise unless building
	
	### Overhead ###
	args.state.renderables.dialog = []
	dialog = args.state.renderables.dialog
	details = args.state.blueprints.structures[building]
	border = {primitive_marker: :border}
	sprite = {primitive_marker: :sprite}
	line = {primitive_marker: :line}
	label = {primitive_marker: :label}
	
	### Layout ###
	dialog_border = args.layout.rect(row: 7, col: 6, w: 12, h: 5).merge(border) 			# Main Dialog
	dialog_ui_line = args.layout.rect(row: 8.5, col: 6.25, w: 11.5, h: 0).merge(border) 	# Dividing line
	
	### Back and Build Buttons ###
	back_button = get_button_from_layout(args.layout.rect(row: 7.25, col: 6.5, w: 1, h: 1), LEFT, :select_building, nil, :back_button, args)
	build_button = get_button_from_layout(args.layout.rect(row: 7.25, col: 15.5, w: 2, h: 1), "Build", :build, building, :build_button, args)
	
	args.state.buttons = [build_button.merge(sprite), back_button.merge(sprite)]

	
	### Title ###
	title_border = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1).merge(border) # Title
	title_loc = args.layout.rect(row: 7.25, col: 8, w: 7, h: 1)
	title = {x: title_loc[:center_x], y: title_loc[:center_y] - 1, 
							text: details[:name], size_enum: 2,
							vertical_alignment_enum: 1, alignment_enum: 1}.merge(label)
	
	### Description ###
	description_loc = args.layout.rect(row: 8.5, col: 6.25, w: 11.5, h: 1) # Description
	description = textbox(details[:description],
						description_loc[:x], description_loc[:center_y], 
						description_loc[:w], 
						size=-2, font="default").each{|t| t.merge!({vertical_alignment_enum: 0, primitive_marker: :label})}

	
	### Cost ###
	cost_ui = get_ui_box_from_layout(args.layout.rect(row: 9.5, col: 6.25, w: 3, h: 2.25), :cost_box, "Cost", args).merge(sprite)

	
	cost_box = args.layout.rect(row: 9.5, col: 6.25, w: 3, h: 2.25).merge(border)
	cost_hash = details[:cost]
	costs_names = cost_hash.keys
	costs_names.map!{|name| {text: name.to_s.capitalize+":", size_enum: -2, alignment_enum: 2, primitive_marker: :label}}
	costs_values = cost_hash.values
	costs_values.map!{|val| {text: val.to_s, size_enum: -2, alignment_enum: 0, primitive_marker: :label}}

	
	cost_labels = args.layout.rect_group(row: 10.1, col: 7.75, drow: 0.4, group: costs_names)

	cost_labels2 = args.layout.rect_group(row: 10.1, col: 7.75, drow: 0.4, group: costs_values)

	
	### Production / Consumption ###
	prod_ui = get_ui_box_from_layout(args.layout.rect(row: 9.5, col: 9.25, w: 8.5, h: 2.25), :prod_box, "Production and Consumption", args).merge(sprite)

	prod_label_box = args.layout.rect(row: 9.8, col: 9.5, w: 8.5, h: 2.25)
	production_hash = details[:production]
	production_text = horizontal_paired_list("Production: ", production_hash, UP, args)
	production_label = {text: production_text, x: prod_label_box[:x], y: prod_label_box[:center_y], size_enum: -1}.merge(label)
	
	con_label_box = args.layout.rect(row: 9.2, col: 9.5, w: 8.5, h: 2.25)
	consumption_hash = details[:consumption]
	consumption_text = horizontal_paired_list("Consumption: ", consumption_hash, DOWN, args)
	consumption_label = {text: consumption_text, x: con_label_box[:x], y: con_label_box[:center_y], size_enum: -1}.merge(label)

	
	dialog << args.state.buttons
	dialog << title
	dialog << title_border
	dialog << description	
	dialog << cost_ui
	dialog << cost_labels
	dialog << cost_labels2
	dialog << prod_ui
	dialog << consumption_label	
	dialog << production_label
	dialog << dialog_border
	dialog << dialog_ui_line
end

def render(args)
	args.outputs.primitives << args.state.renderables.dialog
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

def get_button_from_layout(layout, text, method, argument, target, args)
	make_button(layout[:x], layout[:y], layout[:w], layout[:h], text, method, argument, target, args)
end

def get_ui_box_from_layout(layout, target, text, args)
	make_ui_box(target, text, layout[:w], layout[:h], args).merge({x: layout[:x], y: layout[:y]})
end


def select_building(to_select)
	args.state.selection.building = to_select
end

def init(args)
	args.state.production = Hash.new(0)
	args.state.inventory = Hash.new(0)
	
	args.state.blueprints.structures = {}
	args.state.blueprints.structures[:iron_mine] =
		{	name:		"Iron Ore Mine",
			cost:		{wood: 20},
			production:	{ore: 5},
			available: false,
			description: "Mining tunnels through deep into rock, producing iron ore"
		}
	args.state.blueprints.structures[:woodcutter] =
		{	name:		"Woodcutter's Hut",
			cost:		{wood: 0},
			production:	{wood: 20},
			available: true,
			description: "Shelter for woodcutter and tools, produces wood for construction"
		}
	args.state.blueprints.structures[:smelter] =
		{	name:		"Smelter",
			cost:		{stone: 60, wood: 20, charcoal: 100},
			production:	{iron: 1},
			available: false,
			description: "A tall chimney furnace able to smelt iron ore into usable metal"
		}
	args.state.blueprints.structures[:quarry] =
		{	name:		"Quarry",
			cost:		{wood: 40},
			production:	{stone: 10},
			available: true,
			description: "Scaffolding across a rockface where usable stone is cut from the cliff"
		}
	args.state.blueprints.structures[:charcoal_pile] =
		{	name:		"Charcoal Pile",
			cost:		{wood: 100},
			production:	{charcoal: 2},
			available: true,
			description: "A pile of wood covered in earth and sealed so as to burn down into charcoal. An inefficient way to gain coal-type fuel."
		}
		
	
	args.state.buttons = []

	SIGNS = ["=", "▲", "▼"]
	
	prepare_ui(args)
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
end

def prepare_ui(args)

	args.outputs.static_sprites << make_ui_box(:resources_ui, "Resources", 250, 680, args).merge({x: 1010, y: 20})
	
	BUILD_BOX_LAYOUT = [{x: 10, y:     10, w: 420, h: 130},
						{x: 10, y: 130+20, w: 420, h: 130},
						{x: 10, y: 260+30, w: 420, h: 130},
						{x: 10, y: 390+40, w: 420, h: 130},
						{x: 10, y: 520+50, w: 420, h: 130}
						]
	
	location = 0
	args.state.blueprints.structures.each_key do |building|
		prepare_build_boxes(building, args)
		args.outputs.static_sprites << BUILD_BOX_LAYOUT[location].merge({path: (building.to_s+"_ui_box").to_sym})
		x = BUILD_BOX_LAYOUT[location][:x] + 10
		y = BUILD_BOX_LAYOUT[location][:y] + 10
		w = 80
		h = 50
		args.state.buttons << make_button(x, y, w, h, "Build", :build, building, ("build_" + building.to_s + "button").to_sym, args)
		location += 1
	end
	
	args.outputs.static_sprites << args.state.buttons
end

def prepare_build_boxes(building, args) # key, args
	box = args.render_target(building.to_s + "_ui_box")
	box.height = 130
	box.width = 420
	
	details = args.state.blueprints.structures[building]
	
	box.sprites << make_ui_box(("build_" + building.to_s).to_sym, details[:name], 420, 130, args)
	box.labels << textbox(details[:description], 10, 108, 390, size=-2, font="default")
	box.lines << [10, 70, 410, 70]
	box.sprites << make_ui_box(("cost_"+building.to_s).to_sym, ["Cost", -3, "default"], 150, 55, args).merge({x: 100, y: 10})
	box.sprites << make_ui_box(("production_"+building.to_s), ["Production", -3, "default"], 150, 55, args).merge({x: 100 +150 +10 , y: 10})
	positions = [[105, 17 + 5 + 12 + 12],[105, 17 + 12],[],[]]
	position = 0
	details[:cost].each do |resource, value|
		box.labels << [*positions[position], "#{resource.capitalize}: #{value}", -3]
		position += 1
	end
	
	positions = [[265, 17 + 5 + 12 + 12],[265, 17 + 12],[],[]]
	position = 0
	details[:production].each do |resource, value|
		box.labels << [*positions[position], "#{resource.capitalize}: #{value}", -3]
		position += 1
	end
end



def prepare_resource_counters(args)
	row = 0
	args.state.inventory.each do |resource, stock|
		sign = SIGNS[args.state.production[resource].sign]
		production = sign + " " + args.state.production[resource].abs.to_s
		stock = args.state.inventory[resource]
		stock = stock.idiv(1000).to_s + "k" if stock > 10000
		args.state.ui[resource] = [1030, 650 - row*30, "#{resource.capitalize} : #{stock} (#{production})"]
		args.outputs.labels << args.state.ui[resource]
		row += 1
	end
end

def game_step(args)
	return unless args.tick_count.mod(60) == 0
	args.state.production.each do |resource, amount|
		args.state.inventory[resource] += amount
		args.state.inventory[resource] = 0 if args.state.inventory[resource].negative?
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

# def make_ui_box(target, name, w, h, args)
	# text_width, text_height = *($gtk.calcstringbox(*name))
	# args.outputs[target].primitives << [0, 0, 1280, 720, *$gtk.background_color].solids	
	# args.outputs[target].primitives << [0, 0, w, h, 0, 0, 0].borders
	# args.outputs[target].primitives << [10, h - text_height / 2, text_width + 10, text_height, *$gtk.background_color].solids
	# text, size, font = *name
	# args.outputs[target].primitives << [15, h + text_height / 2, text, size, 0, 0, 0, 0, 255, font].labels
	# args.outputs[target].height = h + text_height / 2
	# args.outputs[target].width = w
	# {w: w, h: h + text_height / 2, path: target}
# end
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



## TEXTBOX BELOW THIS POINT

def textbox(string, x, y, w, size=0, font="default")    # <==<< # THIS METHOD TO BE USED
    text = string_to_lines(string, w, size, font)               # Accepts string and returns array of strings of desired length
	return [{x: x, y: y, text: text, size_enum: size, font: font}] if text.is_a?(String)
    height_offset = get_height(string, size, font)              # Gets maximum height of any given line from the given string
    text.map!.with_index do |line, idx|                         # Converts array of string into array suitable for
        {x: x, y: y - idx * height_offset, text: line, size_enum: size, font: font}          # args.outputs.lables << textbox()
    end
end

def get_length(string, size=0, font="default")  # Internal method utilising calcstringbox to return string box length
    $gtk.args.gtk.calcstringbox(string, size, font).x
end

def get_height(string, size=0, font="default")  # Internal method utilising calcstringbox to return string box height
    $gtk.args.gtk.calcstringbox(string, size, font).y
end

def string_to_lines(string, box_x, size, font)
    return string unless get_length(string, size, font) > box_x
    string.gsub!("\r", '')                                      # Removes carriage returns, leaving only line breaks
    strings_with_linebreaks = string.split("\n")                # splits string into array at linebreak
    list_of_strings = strings_with_linebreaks.map do |line| 
        next if line == ""                                      # Ignores blank strings, as caused by consecutive linebreaks
        line.split                                              # Splits strings into arrays of words at any whitespace
                                                                # Results in nested array, [[],[]]!
    end

    list_to_lines(list_of_strings, box_x, size, font)
end

def list_to_lines(strings, box_x, size, font)
    line = ""                                                   # Define string
    lines = []                                                  # Define array
    strings.map!{|string|
        next unless string                                      # Handles Nil entries from multiple newlines
        string << ""                                            # Adds a blank 'word' to the end of each outer array, to trigger newline code
        }.flatten!.pop                                          # Collapses nested arrays into one array, and removes the trailing blank 'word'
    strings.each do |word|
        if word.empty? || !word                                 # Handling of blank 'words' and Nil entries in arrays 
            lines.push line.dup unless line.empty?              # Adds existing accumulated words to the current line
            lines.push " " if line.empty?                       # Adds a space if no words accrued
            line.clear                                          # Clears the accumulator
        elsif get_length(line + " " + word, size, font) <= box_x    # "If current word fits on the end of the current line, do"
            line << " " if line.length > 0                      # Inserts a space into accumulator if the line isn't blank
            line << word                                        # Adds the current word to the accumulator
        else                                                        # "If the word doesn't fit, instead do"
            lines.push line.dup                                 # Adds accumulator to current line
            line.clear                                          # Clears accumulator
            line << word                                        # Adds current word to accumulator
        end
    end                                                         # Once all words in all strings are processed
    lines.push line.dup                                         # Add accumulator to current line, as it's possible for accumulator to not have been committed
    return lines                                                # Return array of lines, explicitly to be safe.
end