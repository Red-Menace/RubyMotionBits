
# Convert text to an NSMutableAttributedString, with default formatting.
# Returns the new attributed string, or the original text if it is already attributed.
def makeAttributed(parameters = {})
   options = { text: 'text',
               font: NSFont.fontWithName( 'Menlo', size: 12 ),
               traits: 0,  # trait mask (NSBoldFontMask, NSItalicFontMask, etc)
               textColor: NSColor.textColor,
               backgroundColor: NSColor.clearColor,  # use textView background
               underline: false
             }.merge(parameters)
   return options[:text] if options[:text].class.to_s.end_with?('AttributedString')
   paraStyle = NSMutableParagraphStyle.alloc.init.tap do |style|
      style.tabStops = (1..21).each_with_object([]) do |index, tabArray|  # add a few more
         tabArray.addObject(NSTextTab.alloc
                                     .initWithType( NSLeftTabStopType,
                                          location: index * 27.0 ))
      end
   end
   underline = options[:underline] ? NSUnderlineStyleSingle : NSUnderlineStyleNone
   NSMutableAttributedString.alloc.initWithString(options[:text]).tap do |attrText|
      attrText.beginEditing
      [[NSParagraphStyleAttributeName, paraStyle],
       [NSUnderlineStyleAttributeName, underline],
       [NSForegroundColorAttributeName, options[:textColor]],
       [NSBackgroundColorAttributeName, options[:backgroundColor]],
       [NSFontAttributeName, options[:font]]].each do |attribute, value|
         attrText.addAttribute(attribute, value: value, range: [0, attrText.length])
      end
      attrText.applyFontTraits(options[:traits], range: [0, attrText.length])
      attrText.endEditing
   end
end


