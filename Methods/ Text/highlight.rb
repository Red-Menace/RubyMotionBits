
# Add attributes (for highlight, error, etc) to portions of attributed text.
# The matchItem is a string or an array of strings, or if nil, the attributed string.
# Items in the attributes hash are added to all portions that match.
# Returns the attributed text.
def highlight(attrText, matchItem = nil, attrHash = {})
   attributes = { color: NSColor.systemRedColor,   # NSColor
                  tooltip: nil,                    # string
                  traitMask: nil                   # NSBoldFontMask, NSItalicFontMask, etc
                }.merge(attrHash)
   matchItem = attrText.string if matchItem.nil?  # the whole thing
   Array(matchItem).each_with_object(attrText) do |matchText|
      length = matchText.length
      index = -1
      attrText.beginEditing
      while (index = attrText.string.index(matchText, index + 1))
         attrText.addAttribute( NSForegroundColorAttributeName,
                         value: attributes[:color],
                         range: [index, length] ) unless attributes[:color].nil?
         attrText.addAttribute( NSToolTipAttributeName,
                         value: attributes[:tooltip],
                         range: [index, length] ) unless attributes[:tooltip].nil?
         attrText.applyFontTraits( attributes[:traitMask],
                            range: [index, length] ) unless attributes[:traitMask].nil?
      end
      attrText.endEditing
   end
end
