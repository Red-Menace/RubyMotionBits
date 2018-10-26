
# Debug/development logging.
# Uses motion_print gem, replace with p or .inspect as desired.
# Default is 'file -> method', with optional user info and stack trace.
def dlog(userInfo = nil, stackItems = nil)
   return unless RUBYMOTION_ENV == 'development'
   shown, pieces = false, caller.first.split(/\W+/)  # "words"
   print "\e[31m#{pieces[pieces.index('rb') - 1]} -> #{pieces.last}\e[0m  "  # red
   if [String, Integer, Float].include?(userInfo.class)
      mp userInfo  # short stuff on the same line
      shown = true
   else
      puts "\n"  # longer stuff at the end
   end
   mp caller[0..stackItems] unless stackItems.nil?  # upto index, -1 for full stack
   mp userInfo unless userInfo.nil? || shown
end

