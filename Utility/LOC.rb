#!/usr/bin/env ruby

#
# Count the total number of code, comment, and blank lines
# of files with the specified extension.
# Place the script in the root folder of your project.
#
# How low can you go?
#


def countLOC(extension)
   files = 0         # number of files
   locTotal = 0      # total number of lines of code
   commentTotal = 0  # total number of comment lines
   blankTotal = 0    # total number of blank lines

   Dir.glob('./**/*.' + extension).each do |item|
      next if item.index(' LOC.rb') # skip this file
      next if item.index('/spec/') # skip files in the specification directory
      # other items to skip

      files += 1
      loc, comment, blank = 0, 0, 0
      File.new(item).each_line do |line|
         loc += 1
         if line.strip == ''
            blank += 1
            next
         end
         if line.strip[0] == '#'
            comment += 1
            next
         end
      end
      print "(#{files.to_s}) #{item}: #{(loc - comment - blank).to_s} lines of code out of"
      puts " #{loc.to_s} (#{comment.to_s} comments, #{blank.to_s} blank)"
      locTotal += loc
      commentTotal += comment
      blankTotal += blank
   end

   puts
   print "There were #{files.to_s} '.#{extension}' files containing "
   puts "#{(locTotal-commentTotal-blankTotal).to_s} lines of code, with an additional"
   print "#{commentTotal.to_s} comment and #{blankTotal.to_s} blank"
   puts " lines for a total of #{locTotal.to_s} lines of text."
end

puts
countLOC('rb')

