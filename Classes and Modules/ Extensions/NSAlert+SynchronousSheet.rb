
class NSAlert

   # Run a synchronous sheet for a window using asynchronous callback.
   def runModalSheetForWindow(theWindow)
      self.beginSheetModalForWindow( theWindow,
                  completionHandler: lambda do |returnCode|
                                        NSApp.stopModalWithCode(returnCode)
                                     end)
      NSApp.runModalForWindow(self.window)  # window modal event loop
   end
   
   
   # A shortcut for a sheet on the main window.
   def runModalSheet
      self.runModalSheetForWindow(NSApp.mainWindow)
   end
   
end

