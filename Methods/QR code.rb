
# Make a QR code from the input text, saving the image to a posixFile.
def makeQRcode(text, width, posixFile)
   textData = text.dataUsingEncoding(NSUTF8StringEncoding)
   imageFilter = CIFilter.filterWithName('CIQRCodeGenerator')
   imageFilter.setDefaults
   imageFilter.setValue(textData, forKey: 'inputMessage')
   imageFilter.setValue('L', forKey: 'inputCorrectionLevel')
   image = imageFilter.outputImage
   scale = width / image.extent.size.width
   transform = CGAffineTransform.CGAffineTransformMakeScale(scale, scale)
   image.imageByApplyingTransform(transform)
        .TIFFRepresentation
        .writeToFile(posixFile, atomically: true)
end

