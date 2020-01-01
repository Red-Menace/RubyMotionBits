
# Simple:

# Run an AppleScript via the osascript shell utility.
# Returns an array consisting of an error flag and the result/error text
def osascript(script)
   result = `osascript -s o -e '#{script}'`.chomp  # get the result (or error message)
   error = $?.exitstatus == 0  # set error flag
   [error, result]
end


# A bit more robust:

# Run an AppleScript via the osascript shell utility.
# Arguments to a run handler are in the args parameter, items are escaped for the shell.
# Returns an array consisting of an error flag and the result text.
# Note that although the ending newline of the osascript result is stripped, chomp isn't
# used since some items can end with a return ("\r", or 0D), such as file names.
def osascript(script, *args)
   arguments = ''
   args.each do |item|  # escape for the shell
      item.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, '\\\\\\1')
      item.gsub!(/\n/, "'\n'")
      arguments << ' ' + item
   end
   result = `osascript -s o -e '#{script}'#{arguments}`[0..-2]  # result or error message
   error = $?.exitstatus != 0  # set error flag
   [error, result]
end

