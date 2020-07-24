
# Try to get the original item of an alias.
# Returns the original item or an "unable to resolve" string.
def resolveAlias(aliasPath)
   # first try
   aliasURL = NSURL.fileURLWithPath(aliasPath)
   errorPointer = Pointer.new(:object)
   bookmarkData = NSURL.bookmarkDataWithContentsOfURL(aliasURL, error: errorPointer)
   unless bookmarkData
      # try again (2)
      symlink = aliasPath.stringByResolvingSymlinksInPath
      return symlink if symlink != aliasPath
      # and again (3)
      symlink = NSFileManager.defaultManager
                             .destinationOfSymbolicLinkAtPath(aliasPath, error: nil)
      return symlink if symlink != aliasPath
      return "Unable to resolve alias for '#{aliasPath}'"
   end
   stalePointer = Pointer.new(:boolean)
   targetURL = NSURL.URLByResolvingBookmarkData( bookmarkData,
                                        options: NSURLBookmarkResolutionWithoutUI,
                                  relativeToURL: aliasURL,
                            bookmarkDataIsStale: stalePointer,
                                          error: errorPointer)
   return "Unable to resolve alias for '#{aliasPath}'" unless targetURL
   targetURL.path
end

