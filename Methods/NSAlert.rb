
#
# some NSAlert methods - simple, with input, with input plus buttons and icon
#


# Simple modal alert dialog with 'OK' button.
def simpleAlert(infoText = nil, messageText = nil)
   NSAlert.new.tap do |obj|
      obj.messageText = messageText unless messageText.nil?
      obj.informativeText = infoText unless messageText.nil?
   end.runModal
end


# Make and return an NSAlert object.
# Buttons parameter can be a string or array of strings.
def makeAlert(message, withText: infoText, buttons: buttons)
   NSAlert.alloc.init.tap do |obj|
      obj.messageText = message
      obj.informativeText = infoText
      if buttons.count == 0
         obj.addButtonWithTitle('OK')  # default
      else
         buttons.reverse_each { |item| obj.addButtonWithTitle(item) }
      end
   end
end


# Make and show an NSAlert - result is input text, if any.
# An additional button and text field are created if the input parameter is not nil.
def showAlert(message, infoText: infoText, input: input)
   alert = NSAlert.new
   alert.messageText = message
   alert.informativeText = infoText
   alert.addButtonWithTitle('OK')  # default
   if input
      alert.addButtonWithTitle('Cancel')
      textField = NSTextField.alloc.initWithFrame(NSMakeRect(0, 0, 200, 24))
      textField.stringValue = input
      alert.accessoryView = textField
   end
   response = alert.runModal
   if input && response == NSAlertFirstButtonReturn
        textField.stringValue
   else
      ''
   end
end


# Display a custom NSAlert, with options for input text, buttons, and icon.
# A hash is used for input parameters, unspecified keys will use default values.
# A text field is created if the answer or placeholder parameters are not nil.
# Returns a hash: {button:(button title), reply:(text field value, or nil if not used)}
def displayAlert(parameters = {})
   options = {  title: '',            # title for the alert dialog
                message: 'Alert',     # message text (bold)
                info: '',             # informative text (normal)
                answer: nil,          # default textfield text
                placeholder: nil,     # placeholder text for the textfield
                secure: false,        # NSSecureTextField vs NSTextField
                icon: '',             # an icon for the alert, can be a style or path
                buttons: ['OK']       # a list of buttons
             }.merge(parameters)
   alert, buttonList, accessory, theButton = NSAlert.new, []  # init
   Array(options[:buttons]).reverse.each do |aButton|  # left-to-right
      aButton = aButton.to_s
      next if aButton == '' || buttonList.include?(aButton)
      theButton = alert.addButtonWithTitle(aButton)
      theButton.refusesFirstResponder = true  # workaround for more than 3 buttons
      buttonList << aButton
   end
   if buttonList.empty?  # better have at least one
      buttonList = ['OK']
      theButton = alert.addButtonWithTitle('OK')
   end
   theButton.refusesFirstResponder = false
   alert.window.makeFirstResponder(theButton)  # the last one (leftmost)
   unless options[:answer].nil? && options[:placeholder].nil?  # create accessory textField
      alert.layout  # layout the alert from current settings (buttons)
      textField = NSControl.const_get(options[:secure] ? :NSSecureTextField : :NSTextField)
      accessory = textField.alloc.initWithFrame([[0, 0], [2048, 24]]).tap do |obj|
         obj.frameSize = [alert.window.frame.size.width - 125, 24]  # readjust width
         obj.refusesFirstResponder = true  # keep last button as first responder
         obj.stringValue = options[:answer].to_s
         obj.placeholderString = options[:placeholder].to_s
      end
      alert.accessoryView = accessory
   end
   icon = options[:icon].to_s
   case icon.downcase
   when 'critical' then alert.alertStyle = NSCriticalAlertStyle
   when '', 'informational', 'warning'  # everything not a path is NSInformationalAlertStyle
   else  # path to image file
      iconImage = NSImage.alloc.initByReferencingFile(icon)
      alert.icon = iconImage unless iconImage.nil?
   end
   alert.window.title = options[:title].to_s
   alert.messageText = options[:message].to_s
   alert.informativeText = options[:info].to_s
   response = (alert.runModal) - 1000  # buttonList index - 1000 is rightmost button
   {button: buttonList[response], reply: accessory.nil? ? nil : accessory.stringValue}
end

