
# Launch Services path to application registered for extension.
def appForExtension(extension)
   appRef = Pointer.new(FSRef.type)
   result = LSGetApplicationForInfo(KLSUnknownType,
                                    KLSUnknownCreator,
                                    extension,
                                    KLSRolesAll,
                                    appRef,
                                    nil)
   result == 0 ? CFURLCreateFromFSRef(KCFAllocatorDefault, appRef).path : nil
end
   
   