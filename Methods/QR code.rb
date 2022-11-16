
   # Create QR code from the input text, saving the image to an output file.
   def makeQRcode(inputText, outputFile, options = {})
      imageSize = options.fetch(:imageSize, 256)
      correctionLevel = options.fetch(:correctionLevel, nil)
      textData = inputText.dataUsingEncoding(NSUTF8StringEncoding)
      imageFilter = CIFilter.filterWithName('CIQRCodeGenerator')
      imageFilter.setDefaults
      imageFilter.setValue(textData, forKey: 'inputMessage')
      if !correctionLevel.nil? && ['L', 'M', 'Q', 'H'].include?(correctionLevel)
         imageFilter.setValue(correctionLevel, forKey: 'inputCorrectionLevel')
      end
      image = imageFilter.outputImage
      scale = imageSize / image.extent.size.width
      transform = CGAffineTransform.CGAffineTransformMakeScale(scale, scale)
      image.imageByApplyingTransform(transform)
           .TIFFRepresentation
           .writeToFile(outputFile, atomically: true)
   end
   
   
   # Return text of the QR code from the input File.
   def readQRcode(inputFile)
      fileURL = NSURL.fileURLWithPath(inputFile)
      image = CIImage.imageWithContentsOfURL(fileURL)
      if (image = CIImage.imageWithContentsOfURL(fileURL))
         options = {CIDetectorAccuracy: 'CIDetectorAccuracyHigh'}
         detector = CIDetector.detectorOfType( 'CIDetectorTypeQRCode',
                                      context: nil,
                                      options: options )
         features = detector.featuresInImage(image, options:options)
         return features[0].messageString unless Array(features).empty?
      end
      nil
   end

