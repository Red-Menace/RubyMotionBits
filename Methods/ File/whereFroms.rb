
# Add a whereFrom to beginning of the list - default text is the current item path.
# The list is trimmed after the item is added (duplicates are moved to the beginning).
# Spotlight may take a moment to update.
def addWhereFrom(posixPath)
   max = 5  # maximum number of items
   existing = readWhereFroms(posixPath)
   index = existing.index(entry[:reply])  # duplicate?
   newList = existing.delete_at(index) if index
   newList = existing.unshift(entry[:reply])  # add to beginning
   writeWhereFroms(posixPath, newList.first(max))  # trim to maximum number of items
end


# Read the current whereFroms binary property list from the extended attribute.
# Returns a list of the whereFroms.
def readWhereFroms(posixPath)
   result = `xattr -px com.apple.metadata:kMDItemWhereFroms #{shellEscape posixPath} 2>&1`
   return [] if $?.exitstatus != 0  # read error (no attribute, etc)
   attribute = `echo "#{result}" | xxd -r -p | plutil -convert xml1 -o - -`
   data = attribute.dataUsingEncoding(NSUTF8StringEncoding)
   NSPropertyListSerialization.propertyListWithData( data,
                                            options: NSPropertyListMutableContainersAndLeaves,
                                             format: nil,
                                              error: nil ).to_a
end


# Write a new whereFroms binary property list to the extended attribute.
def writeWhereFroms(posixPath, itemList)
   data = NSPropertyListSerialization.dataWithPropertyList( Array(itemList),
                                                    format: NSPropertyListXMLFormat_v1_0,
                                                   options: 0,
                                                     error: nil )
   plist = NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
   bplist = `echo #{shellEscape plist} | plutil -convert binary1 -o - - | xxd -p`
   `xattr -wx com.apple.metadata:kMDItemWhereFroms '#{bplist}' #{shellEscape posixPath}`
end


# Escape characters for the shell. Similar to Shellwords::shellescape
def shellEscape(text)
   text = text.to_s
   return "''" if text.empty?
   escaped = text.dup
   escaped.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, '\\\\\\1')
   escaped.gsub!(/\n/, "'\n'")
   escaped
end

