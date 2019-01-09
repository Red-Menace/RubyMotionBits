
# Post "Download Finished" notification (bounces "Downloads" Dock icon).
NSDistributedNotificationCenter.defaultCenter
                               .postNotificationName( 'com.apple.DownloadFileFinished',
                                              object: '/path/to/some/file')


# Observe "Download Finished" notification.
NSDistributedNotificationCenter.defaultCenter
                               .addObserver( self,
                                   selector: 'downloadFinished:',
                                       name: 'com.apple.DownloadFileFinished',
                                     object: nil,
                         suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately)


# "Download Finished" notification selector.
# The name of the downloaded item is in the notification's object.
def downloadFinished(notification)
   puts notification.object  # whatever
end


# Request attention if app is not frontmost (bounces application Dock Icon).
NSApp.requestUserAttention(requestType)

