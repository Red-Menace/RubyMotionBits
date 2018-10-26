
# Get the name extension for a file path.
# First tries to get what the Finder sees as an extension (since there can be
# a period in a file name with no extension), and if there is an error (not a
# file, etc) then whatever is after the final period.
# Returns '.extension' or an empty string.
def extensionFor(posixPath)
   tellApp = 'tell application id "com.apple.finder"'
   theFile = "file (POSIX file \"#{posixPath}\" as text)"
   result = `osascript -s o -e '#{tellApp} to get name extension of #{theFile}'`.chomp
   result = posixPath.pathExtension if $?.exitstatus != 0 # error
   (result == '') ? result : ('.' + result)
end


