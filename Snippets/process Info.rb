# NSProcessInfo (OS X Yosemite 10.10+)

NSProcessInfo.processInfo.tap do |obj|
   p version = obj.operatingSystemVersion  # majorVersion, minorVersion, patchVersion
   p versionString = obj.operatingSystemVersion.to_a.join('.')
   p obj.operatingSystemVersionString  # "Version 10.xx.x (Build xxxxxxx)"
   p obj.isOperatingSystemAtLeastVersion([10, 10, 3])
end

