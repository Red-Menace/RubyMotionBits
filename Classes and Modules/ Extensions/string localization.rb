
# Class extensions for localization.
# Most spoken ISO 639-1 codes:
#     English     en
#     Chinese     zh
#     Hindi       hi
#     Spanish     es
#     Arabic      ar
#     Indonesian  id
#     Russian     ru
#     Bengali     bn
#     Portugese   pt
#     French      fr
#     German      de
#     Japanese    ja
#     


class String

   # Return a localized string.
   # Optionally from the specified table and language bundle (en, ja, fr, etc).
   def localized(value = nil, table = nil, languageCode = nil)
      bundle = NSBundle.mainBundle
      unless languageCode.nil? || languageCode == bundle.preferredLocalizations.first
         path = NSBundle.mainBundle.pathForResource(languageCode, ofType: 'lproj')
         bundle = NSBundle.bundleWithPath(path) unless path.nil?
      end
      bundle.localizedStringForKey(self, value: value, table: table)
   end

end


class Array

   # Return an array of localized strings.
   # Optionally from the specified table and language bundle (en, ja, fr, etc).
   def localized(value = nil, table = nil, languageCode = nil)
      bundle = NSBundle.mainBundle
      unless languageCode.nil? || languageCode == bundle.preferredLocalizations.first
         path = NSBundle.mainBundle.pathForResource(languageCode, ofType: 'lproj')
         bundle = NSBundle.bundleWithPath(path) unless path.nil?
      end
      self.map do |item|
         bundle.localizedStringForKey(item.to_s, value: value, table: table)
      end
   end

end

