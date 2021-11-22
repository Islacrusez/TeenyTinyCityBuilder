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
			production:	{ore: 5},
			available: false
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
			cost:		{stone: 60, wood: 20},
			production:	{iron: 1},
			available: false
		}
	args.state.blueprints.structures[:quarry] =
		{	name:		"Quarry",
			cost:		{wood: 40},
			production:	{stone: 10},
			available: true
		}
		
	
	args.state.buttons = []
	args.state.buttons << make_button(600, 300, 120, 40, "Build Mine", :build, :iron_mine, :mine_button, args)
	args.state.buttons << make_button(600, 400, 180, 40, "Build Woodcutter", :build, :woodcutter, :woodcutter_button, args)

	args.state.buttons << make_button(20, 520 + 60, 80, 50, "Build", :build, :woodcutter, :build_button, args)


	SIGNS = ["=", "▲", "▼"]
	
	prepare_ui(args)
	
	# UP = ▲
	# DOWN = ▼
	
	args.state.ready = true
	$gtk.notify!("Init complete!")
end

def prepare_ui(args)

	args.outputs.static_sprites << make_ui_box(:resources_ui, "Resources", 250, 680, args).merge({x: 1010, y: 20})
	
	# args.state.blueprints.structures.each do |building, building_details|
		
	# end
	
	# woodcutter = args.render_target(:woodcutter_ui_box)
	# woodcutter.height = 130
	# woodcutter.width = 420
	
	# woodcutter.sprites << make_ui_box(:build_woodcutter, "Woodcutter", 420, 130, args)
	# #woodcutter.labels << [10, 80, args.state.blueprints.structures[:woodcutter][:description], -2]
	# woodcutter.labels << textbox(args.state.blueprints.structures[:woodcutter][:description], 10, 108, 390, size=-2, font="default")
	# woodcutter.lines << [10, 70, 410, 70]
	# woodcutter.sprites << make_ui_box(:cost_woodcutter, ["Cost", -3, "default"], 150, 55, args).merge({x: 100, y: 10})
	# woodcutter.sprites << make_ui_box(:production_woodcutter, ["Production", -3, "default"], 150, 55, args).merge({x: 100 +150 +10 , y: 10})
	# positions = [[105, 17 + 5 + 12 + 12],[105, 17 + 12],[],[]]
	# position = 0
	# args.state.blueprints.structures[:woodcutter][:cost].each do |resource, value|
		# woodcutter.labels << [*positions[position], "#{resource.capitalize}: #{value}", -3]
		# position += 1
	# end
	
	# positions = [[265, 17 + 5 + 12 + 12],[265, 17 + 12],[],[]]
	# position = 0
	# args.state.blueprints.structures[:woodcutter][:production].each do |resource, value|
		# woodcutter.labels << [*positions[position], "#{resource.capitalize}: #{value}", -3]
		# position += 1
	# end
	
	prepare_build_boxes(:woodcutter, args)
	#args.outputs.static_sprites << {x: 10, y: 10, w: 420, h: 130, path: :woodcutter_ui_box}
	args.outputs.static_sprites << {x: 10, y: 130+20, w: 420, h: 130, path: :woodcutter_ui_box}
	args.outputs.static_sprites << {x: 10, y: 260+30, w: 420, h: 130, path: :woodcutter_ui_box}
	args.outputs.static_sprites << {x: 10, y: 390+40, w: 420, h: 130, path: :woodcutter_ui_box}
	args.outputs.static_sprites << {x: 10, y: 520+50, w: 420, h: 130, path: :woodcutter_ui_box}
	
	
	
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
	
	args.outputs.static_sprites << {x: 10, y: 10, w: 420, h: 130, path: :woodcutter_ui_box}
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
    height_offset = get_height(string, size, font)              # Gets maximum height of any given line from the given string
    text.map!.with_index do |line, idx|                         # Converts array of string into array suitable for
        [x, y - idx * height_offset, line, size, font]          # args.outputs.lables << textbox()
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