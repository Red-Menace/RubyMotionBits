
# Add a text color attribute (error, etc) to portions of attributed text.
# The matchItem is a string or an array of strings, or if nil, the attributed text string.
# The attribute is added to all portions that match.
# Returns the attributed text.
def colorHighlight(attrText, matchItem, color = NSColor.systemRedColor)
   matchItem = attrText.string if matchItem.nil?  # match the whole thing
   Array(matchItem).each do |matchText|
      length = matchText.length
      index = -1
      while (index = attrText.string.index(matchText, index + 1))
         attrText.addAttribute( NSForegroundColorAttributeName,
                         value: color,
                         range: [index, length] )
      end
   end
   attrText
end

