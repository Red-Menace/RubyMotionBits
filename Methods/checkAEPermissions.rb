
   # Check if authorized to send AppleEvents.
   def checkAEPermissions( bundleID,
                           askIfNeeded = true,
                           eventClass = TypeWildCard,
                           eventID = TypeWildCard )
      appDescriptor = NSAppleEventDescriptor.descriptorWithBundleIdentifier(bundleID)
      status = AEDeterminePermissionToAutomateTarget( appDescriptor.aeDesc,
                                                      eventClass,
                                                      eventID,
                                                      askIfNeeded )
      case status
      when 0 then  # noErr
         p "authorized"
         true
      when -1744 then  # errAEEventWouldRequireUserConsent
         p "need to ask"
         true
      when -600 then  # procNotFound
         p "app not running"
         true
      else
         p "not permitted or unknown"  # -1743 errAEEventNotPermitted
         false
      end
   end

