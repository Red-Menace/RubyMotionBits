
# Check for a match with switch values (yes/no, on/off, etc).
# Returns true/false if argument matches a switch, otherwise nil.
def switch?(parameter)
   return true if %W[true on yes start begin 1].include?(parameter.to_s.downcase)
   return false if %W[false off no stop end 0].include?(parameter.to_s.downcase)
   nil
end

