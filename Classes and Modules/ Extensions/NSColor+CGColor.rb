
class NSColor

   # Get a CGColor from a CIColor.
   def self.CGColorFromCIColor(ciColor)
      CGColorCreate(ciColor.colorSpace, ciColor.components)
   end


   # Get a CGColor from an NSColor.
   def self.CGColorFromNSColor(nsColor)
      NSColor.CGColorFromCIColor(CIColor.alloc.initWithColor(nsColor))
   end


   # Get an NSColor from a CGColor.
   def  self.NSColorFromCGColor(cgColor)
      NSColor.colorWithCIColor(colorWithCGColor(cgColor))
   end

end

