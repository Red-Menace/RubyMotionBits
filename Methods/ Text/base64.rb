
# base64 encode/decode

test = 'This is some testing text. Some testing text this is.'
# QmFzZTY0IGVuY29kZSB0aGlzIHRleHQuCg==


p example = encodeBase64(test)
p decodeBase64(example)

def encodeBase64(text)
   text.dataUsingEncoding(NSUTF8StringEncoding).base64EncodedStringWithOptions(0)
end

def decodeBase64(text)
   NSData.alloc.initWithBase64EncodedString(text, options: 1).to_s
end


p example = `echo "#{test}" | openssl enc -base64`.chomp
p `echo "#{example}" | openssl enc -d -base64`.chomp

