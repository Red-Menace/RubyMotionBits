#!/usr/bin/env ruby

#
# Count code, comment, and blank lines.
# Place the script in the folder containing the project files.
#
# How low can you go?
#


# Count the total number of code, comment, and blank lines for folder contents
# with the specified extension and comment markers.
# To specify a comment block, e.g. AppleScript (* *), Ruby =begin =end, etc,
# place begin/end markers at the beginning and end of the comment array. 
def countLOC(extension, comment)
   comment = Array(comment)  # string or array, will be converted to regexp
   files = 0         # number of files
   totalLOC = 0      # total number of lines of code
   totalComments = 0 # total number of comment-only lines
   totalBlanks = 0   # total number of blank lines

   Dir.glob('./**/*.' + extension).sort.each do |item|
      next if item.index('LOC.rb') ||  # skip this file
              item.index('/spec/')     # skip files in the specification directory
              # other items to skip
      files += 1
      loc, comments, blanks = 0, 0, 0
      blockComment = false  # flag for counting lines in a comment block
      File.open(item, "r:UTF-8").each_line do |line|
         candidate = line.strip
         if candidate == ''
            blanks += 1
            next
         end
         if blockComment || candidate.start_with?(Regexp.union(comment))
            blockComment = true if candidate.start_with?(comment[0])  # single block start
            comments += 1
            blockComment = false if candidate.end_with?(comment[-1])  # single block end
            next
         end
         loc += 1
      end
      print "(#{files.to_s}) #{item}: #{loc.to_s} lines of code out of"
      puts " #{(loc + comments + blanks).to_s} (#{comments.to_s} comment, #{blanks.to_s} blank)"
      totalLOC += loc
      totalComments += comments
      totalBlanks += blanks
   end

   puts
   print "There were #{files.to_s} '.#{extension}' files containing "
   puts "#{totalLOC.to_s} lines of code, with an additional"
   print "#{totalComments.to_s} comment and #{totalBlanks.to_s} blank"
   puts " lines for a total of #{(totalLOC + totalComments + totalBlanks).to_s} lines of text."
end

puts
countLOC('rb', ['=begin', '#', '=end'])
# countLOC('applescript', ['(*', '#', '--', '*)'])

