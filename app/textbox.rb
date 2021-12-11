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