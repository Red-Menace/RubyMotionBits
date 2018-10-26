
# Get a file URL from a bookmark/alias.
# Returns NSURL or error.
def bookmarkToURL(bookmark)
   errorPointer = Pointer.new(:object)
   url = NSURL.URLByResolvingBookmarkData( bookmark,
                                  options: NSURLBookmarkResolutionWithoutUI,
                            relativeToURL: nil,
                      bookmarkDataIsStale: nil,
                                    error: errorPointer)
   errorPointer[0] ? errorPointer[0].localizedDescription : url
end


# Get a bookmark/alias for a file URL.
# Returns NSData or error.
def urlToBookmark(url)
   errorPointer = Pointer.new(:object)
   bookmark = url.bookmarkDataWithOptions( NSURLBookmarkCreationPreferFileIDResolution,
           includingResourceValuesForKeys: nil,
                            relativeToURL: nil,
                                    error: errorPointer)
   errorPointer[0] ? errorPointer[0].localizedDescription : bookmark
end

