
# get the original item of an alias
# Returns the original item or 'unable' string
def resolveAlias(aliasPath)
   # try #1
   aliasURL = NSURL.fileURLWithPath(aliasPath)
   errorPointer = Pointer.new(:object)
   bookmarkData = NSURL.bookmarkDataWithContentsOfURL(aliasURL, error: errorPointer)
   unless bookmarkData  # try #2
      symlink = aliasPath.stringByResolvingSymlinksInPath
      return symlink if symlink != aliasPath
      return "Unable to resolve alias for '#{aliasPath}'"
   end
   # try #3
   stalePointer = Pointer.new(:bool)
   stalePointer[0] = false
   targetURL = NSURL.URLByResolvingBookmarkData( bookmarkData,
                                        options: NSURLBookmarkResolutionWithoutUI,
                                  relativeToURL: aliasURL,
                            bookmarkDataIsStale: stalePointer,
                                          error: errorPointer)
   return "Unable to resolve alias for '#{aliasPath}'" unless targetURL
   targetURL.path
end

