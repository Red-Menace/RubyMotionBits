   
# Guess the language of the sample string (macOS 10.7+).
def guessLanguage(sampleString)
   scheme = NSLinguisticTagSchemeLanguage
   tagger = NSLinguisticTagger.alloc.initWithTagSchemes([scheme], options:0)
   tagger.string = sampleString
   tagger.tagAtIndex(0, scheme:scheme, tokenRange:nil, sentenceRange:nil)
end

