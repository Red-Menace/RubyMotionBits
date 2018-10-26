
# Fetch events and pass them on - e.g. use in a loop to keep UI responsive.
def fetchEvents(eventMask = NSAnyEventMask, mode = NSDefaultRunLoopMode)
   while (event = NSApp.nextEventMatchingMask( eventMask,
                                    untilDate: nil,
                                       inMode: mode,
                                      dequeue: true)) do
      NSApp.sendEvent(event)
   end
end

