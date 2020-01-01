
# Return a URL to a standard location in the user's home directory.
# If the location reference is not valid, the home directory is returned.
def URLFor(locationRef)
   theLocation = NSFileManager.defaultManager
                              .URLsForDirectory( locationRef,
                                      inDomains: NSUserDomainMask)
                              .first
   theLocation.nil? ? NSURL.fileURLWithPath(NSHomeDirectory()) : theLocation
end


