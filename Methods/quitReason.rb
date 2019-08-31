
   # Determine how the application is quitting.
   # returns the reason descriptor or the application calling for the quit
   def quitReason
      appleEvent = NSAppleEventManager.sharedAppleEventManager.currentAppleEvent
      return 'Quit' unless appleEvent  # normal quit
      reason = appleEvent.attributeDescriptorForKeyword(KAEQuitReason)
      return case reason.typeCodeValue
             when KAEQuitAll then 'QuitAll'
             when KAEReallyLogOut then 'Logout'
             when KAERestart then 'Restart'
             when KAEShutDown then 'ShutDown'
             else reason
             end unless reason.nil?
      senderPID = appleEvent.attributeDescriptorForKeyword(KeySenderPIDAttr).int32Value
      sender = NSRunningApplication.runningApplicationWithProcessIdentifier(senderPID)
      sender.bundleIdentifier unless sender.nil?
   end

