
# Run an AppleScript via the osascript shell utility.
# Returns an array consisting of an error flag and the result/error text
def osascript(script)
   result = `osascript -s o -e '#{script}'`.chomp  # get the result (or error message)
   error = $?.exitstatus == 0 ? false : true  # set error flag
   [error, result]
end

