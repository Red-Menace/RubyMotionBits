
# Add the specified text (error, rename result, etc) to a log file.
# The log entry is prefixed with a separator and time stamp if 'prefix' is trueish.
# The log file is placed in the user's library folder at ~/Library/Logs/AppName.log
def addToLogFile(logText, withPrefix: prefix)
   libraryPath = NSHomeDirectory() + '/Library/Logs/'
   name = "#{NSBundle.mainBundle.infoDictionary['CFBundleName']}"
   prefixText = ''
   if prefix
      prefixText += "************************************************************\n"
      prefixText += NSDate.date
                          .descriptionWithCalendarFormat( CALENDAR_FORMAT,
                                                timeZone: nil,
                                                  locale: nil)
      prefixText += (' ' + name)
      prefixText += (' ' + prefix.to_s) if prefix.class != TrueClass  # skip boolean
      prefixText += "\n"
   end
   File.open(libraryPath + name + '.log', 'a') { |file| file.write("#{prefixText}#{logText}") }
end


