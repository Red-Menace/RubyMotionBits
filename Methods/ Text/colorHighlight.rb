
# Add a text color attribute (error, etc) to attributed text.
# The matchItem is a regular string or an array of strings.
# The attribute is added to all matches.
# Returns the attributed text.
def colorHighlight(attrText, matchItem, color)
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

