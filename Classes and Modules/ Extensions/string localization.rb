
class String

   # Return a localized string.
   def localized(value = nil, table = nil)
      NSBundle.mainBundle.localizedStringForKey(self, value: value, table: table)
   end

end


class Array

   # Return an array of localized strings.
   def localized(value = nil, table = nil)
      self.map do |item|
         NSBundle.mainBundle.localizedStringForKey(item.to_s, value: value, table: table)
      end
   end

end

