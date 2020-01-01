
# Get a unique file name, adding a suffix if needed.
def uniqueNameFor(someName, inFolder: folderPath)
   separator = ' '   # text between the name and suffix
   counter = 0       # starting suffix, see below
   padding = 0       # zero padding to number of places
   formatString = '%0' + padding.to_s + 'd'
   
   name, extension = someName.split(/\.([^.]*)$/)
   extension = extension.nil? ? '' : '.' + extension
   
   if counter < 1  # always add a suffix starting at 1
      counter = 1
      newName = name + separator + format(formatString, counter) + extension
   else  # start with specified suffix only if the name already exists
      counter -= 1  # adjust for while loop
      newName = name + extension
   end
   
   files = Dir.entries(folderPath)
   while files.include?(newName)
      newName = name + separator + format(formatString, counter += 1) + extension
   end
   newName
end

