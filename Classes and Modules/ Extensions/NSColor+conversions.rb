
class NSColor

   # Get the RGB components for an NSColor (calibrated/generic color space or CGColor).
   # Returns an RGBA array e.g. [1.0, 0.5, 0.0, 1.0], or nil if unable to convert
   def to_rgb
      if (rgb = self.colorUsingColorSpaceName(NSCalibratedRGBColorSpace))
         [rgb.redComponent, rgb.greenComponent, rgb.blueComponent, rgb.alphaComponent]
      else  # oops, try CGColor
         rgb = CGColorGetComponents(self.CGColor)
         return nil unless rgb.count > 3  # pattern, etc
         [rgb[0], rgb[1], rgb[2], rgb[3]]
      end
   end


   # Get a hexadecimal value for an NSColor - see Apple Technical Q&A QA1576 (legacy).
   # Returns an RGB hex color e.g. #0088FF (values wrap at FF), or nil if unable to convert.
   def to_hex
      return nil unless (rgb = self.to_rgb)
      red = (rgb[0] * 255.99999 % 255).round
      green = (rgb[1] * 255.99999 % 255).round
      blue = (rgb[2] * 255.99999 % 255).round
      format('#%02X%02X%02X', red, green, blue)
   end


   # Get complementary color for an NSColor (RGB component values limited to (0.0..1.0)).
   # Returns an NSColor (alpha component is unchanged), or nil if unable to convert.
   def opposite
      return nil unless (rgb = self.to_rgb)
      NSColor.colorWithCalibratedRed( (1.0 - [0.0, rgb[0], 1.0].sort[1]).round(2),
                               green: (1.0 - [0.0, rgb[1], 1.0].sort[1]).round(2),
                                blue: (1.0 - [0.0, rgb[2], 1.0].sort[1]).round(2),
                               alpha: rgb[3])
   end

end

