
# Get a URL from bookmark data.
# Returns the URL or error.
def bookmarkToURL(bookmark)
   errorPointer = Pointer.new(:object)
   url = NSURL.URLByResolvingBookmarkData( bookmark,
                                  options: NSURLBookmarkResolutionWithoutUI,
                            relativeToURL: nil,
                      bookmarkDataIsStale: nil,
                                    error: errorPointer)
   errorPointer[0] ? "Error:  #{errorPointer[0].localizedDescription}" : url
end


# Get bookmark data for a URL.
# Returns NSData or error.
def urlToBookmark(url)
   errorPointer = Pointer.new(:object)
   bookmark = url.bookmarkDataWithOptions( NSURLBookmarkCreationPreferFileIDResolution,
           includingResourceValuesForKeys: nil,
                            relativeToURL: nil,
                                    error: errorPointer)
   errorPointer[0] ? "Error:  #{errorPointer[0].localizedDescription}" : bookmark
end

