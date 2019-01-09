
# Escape characters for the shell - same as Shellwords::shellescape.
def shellEscape(text)
   escaped = text.dup.to_s
   return "''" if escaped.empty?
   escaped.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")
   escaped.gsub!(/\n/, "'\n'")
   escaped
end

