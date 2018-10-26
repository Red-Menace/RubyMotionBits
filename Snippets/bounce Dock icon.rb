# Bounce a Dock icon

# Downloads folder
# post "com.apple.DownloadFileFinished" notification
NSDistributedNotificationCenter.defaultCenter
                               .postNotificationName( 'com.apple.DownloadFileFinished',
                                              object: '/Users/you/Downloads/somefilename')


# Downloads folder
# observe "com.apple.DownloadFileFinished" notification
NSDistributedNotificationCenter.defaultCenter
                               .addObserver( self,
                                  selector : 'methodName:',
                                       name: 'com.apple.DownloadFileFinished',
                                     object: nil,
                         suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately)


# Application Icon
# request attention (if app is not frontmost)
NSApp.requestUserAttention(requestType)

