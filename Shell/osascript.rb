
# Simple:

# Run an AppleScript via the osascript shell utility.
# Returns the result text or nil if an error.
def runScript(script)
   result = `osascript -s o -e '#{script}'`.chomp
   if $?.exitstatus != 0  # script error
      puts result  # just log it
      nil
   else
      result
   end
end


# A few more options:

# Run an AppleScript via the osascript shell utility.
# Arguments to a run handler are in the args parameter, items are escaped for the shell.
# Returns an array consisting of an error boolean and the result text.
# Note that the ending newline of the result is stripped, but chomp isn't
# used since items such as file names can end with a return ("\r", or 0D).
def osascript(script, *args)
   arguments = ''
   args.each do |item|  # escape for the shell
      item.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, '\\\\\\1')
      item.gsub!(/\n/, "'\n'")
      arguments << ' ' + item
   end
   [$?.exitstatus != 0, `osascript -s o -e '#{script}'#{arguments}`[0..-2]]
end


# Run an AppleScript via NSAppleScript.
# Returns an array consisting of an error boolean and the result string.
def runNSAppleScript(script)
   result = NSAppleScript.alloc
                         .initWithSource(script)
                         .executeAndReturnError(errorPtr = Pointer.new(:object))
   if result
      return [false, result.stringValue]
   else
      errMess, errNum = errorPtr[0].values_at('NSAppleScriptErrorMessage',
                                              'NSAppleScriptErrorNumber')
      return [true, "Error: #{errMess}  (#{errNum})"]
   end
end

