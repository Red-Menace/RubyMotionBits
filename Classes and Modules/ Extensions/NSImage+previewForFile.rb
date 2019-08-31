
class NSImage

   # Get an image containing a QuickLook preview of the content of a given file.
   # If no preview is available, the file's Finder icon is returned instead.
   # The icon parameter is a boolean flag indicating whether the preview should be
   # rendered as an icon, i.e. with a document border, drop-shadow, page-curl, etc.
   def self.previewForFile(posixPath, ofSize: size, asIcon: icon)
      return nil unless posixPath && (fileURL = NSURL.fileURLWithPath(posixPath))
      image = nil
      options = { KQLThumbnailOptionIconModeKey => icon }
      imageRef = QLThumbnailImageCreate( KCFAllocatorDefault, fileURL, size, options)
      if imageRef  # the preview
         bitmapImageRep = NSBitmapImageRep.alloc.initWithCGImage(imageRef)
         if bitmapImageRep
            image = NSImage.alloc.initWithSize(bitmapImageRep.size)
            image.addRepresentation(bitmapImageRep)
         end
      else  # default to the file's icon
        image = NSWorkspace.sharedWorkspace.iconForFile(posixPath)
        image.size = size
      end
      image
   end

end

