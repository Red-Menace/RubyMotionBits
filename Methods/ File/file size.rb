
# Get the size of a file item.
# Totals include package/bundle contents and invisible items such as .DS_Store.
# Returns an array consisting of the number of items and the total bytes.
def calculateSize(posixPath)
   total, items = 0, 0
   formattedItems = ''
   if @directory
      NSFileManager.defaultManager
                   .enumeratorAtURL( NSURL.fileURLWithPath(posixPath, isDirectory: true),
         includingPropertiesForKeys: ['NSURLTotalFileSizeKey'],
                            options: 0,
                       errorHandler: nil)
                   .each do |fileURL|
         total += fileSize(fileURL)
         items += 1
   else
      total = fileSize(NSURL.fileURLWithPath(posixPath, isDirectory: false))
      items += 1
   end
   [items, total]
rescue => error
   ''
end


# Returns an individual file size.
def fileSize(fileURL)
   valuePointer = Pointer.new(:object)
   result = fileURL.getResourceValue( valuePointer,
                              forKey: 'NSURLTotalFileSizeKey',
                               error: nil)
   (!result || valuePointer[0].nil?) ? 0 : valuePointer[0]
end

