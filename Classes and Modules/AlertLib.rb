#
# AlertLib - a library for creating NSAlert modal dialogs
#
# Created by Red_Menace on 07-22-17, last updated/reviewed on 02-03-24
# Copyright (c) 2017-2024 Menace Enterprises, red_menace|at|menace-enterprises|dot|com
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# Thought I might try my hand at a little metaprogramming, in this case a library for
# NSAlert modal dialogs.  A standard dialog can be created and enhanced (accessoryViews,
# fonts, colors, etc) by using method names in a block with Class#new.
#
# An accessoryView is only created if there is an input, and can be a comboBox,
# radioButton or checkBoxes (for input), or a textField (for input/output).  Fonts
# for the default label fields can also be changed, and the alert message label can
# be hidden (more-or-less).
#
# Nothing too fancy with the textField, it is mostly intended for shell formatted output
# and user input (it is editable).  Note that since it is a textField and not a textView,
# there are no scroll bars - scrolling can be done with the arrow keys if needed.
#
# If a specific size isn't declared, the textField will try to auto-size its width to
# the dialog width and its height to contain the text, and the others will auto-size
# their widths to the longest string in the input list (their heights are sized for a
# normal single line).
#
# TextField contents can be changed for re-displaying an existing alert, but most
# of the alert interface items (buttons, accessoryView, etc), including the original
# size of the textFields, can't be changed after the alert has been created.
#
# The checkbox and radiobutton accessoryViews are identical except for the way the
# buttons operate, and radiobutton will only let one button be set.
# Hash#select for value == 1 can be used to get the selection(s).
#
# NOTE:  No checks are done to ensure the dialog fits in the dislay, so constraints can
#        be blown out if auto-sizing the width, using more buttons (there isn't a limit),
#        or setting a larger dialog size than what will fit.
#
# The alert reply varies a little bit depending on the accessoryView used, but consists
# of a hash of the button pressed (or "gave up" if it timed out) and the accessoryView
# values (if any), for example:
#  { button: "Whatever", reply: nil }  # no accessory (or Cancel button)
#  { button: "OK", reply: "This is a test." }  # textField and comboBox
#  { button: "OK", reply: {"checkBox 1": 1, "checkBox 2": 0} }  # checkBox and radiobutton
#
# The remaining delay/give up time (if used) is shown under the alert icon.
#
# Typical usage:
#     initialize an alert via Ruby's new, setting parameters as desired in its block
#     show the alert
#     do something with the response
#
# NSAlert class extensions:
#     runModalSheet                       # run as a modal sheet over the main window
#     runModalSheetForWindow(theWindow)   # run the sheet over the specified window
#
# Class methods:
#     showAlert(infoText, messageText) # show a basic alert with a single 'OK' button
#     getColor(colorName, default)     # get an NSColor from a name - see COLORS constant
#
# Instance methods:
#     display                       # display the alert using the current settings
#     title(titleText)              # alert title
#     message(messageText, messageFont)   # alert message text (bold)
#     info(infoText, infoFont)      # informative text
#     icon(iconType)                # alert icon
#     buttons(buttonArray, default) # the alert buttons
#     giveUp(delayTime)             # a give up time, after which the alert is dismissed
#     sheet(flag)                   # show the alert as a sheet
#     help(info, message)           # show a button for a help alert
#
#     accessory(accessoryType)      # accessoryView type
#     input(item)                   # input item(s) for the accessoryView
#     labels(item)                  # labels for input item(s)
#     textColor(colorName, target)  # text color for the textField or label fields
#     backgroundColor(colorName, target)  # background color for the textField or window
#     borderColor(colorName)        # border color for the textField or check/radio box
#     placeholder(placeholderText)  # placeholder text
#     secure(flag)                  # set the textField to be secure/obscured
#     border(borderStyle)           # accessory border style (none, line, or color)
#     width(accessoryWidth)         # accessory width
#     height(accessoryHeight)       # accessory height
#
#
# Terms to search for if localizing:
#     'OK'
#     'Cancel'
#     'MEalert: %s method not found'
#     'gave up'
#     'Enter text or select an item from the menu'
#


##################################################
#  #mark ―――― Class Extensions ――――
##################################################

class NSAlert

   # Run a synchronous sheet for a window using asynchronous callback.
   def runModalSheetForWindow(theWindow)
      self.beginSheetModalForWindow( theWindow,
                  completionHandler: lambda { |reply| NSApp.stopModalWithCode(reply) } )
      NSApp.runModalForWindow(self.window)  # window modal event loop
   end
   
   
   # A shortcut for a sheet on the main window.
   def runModalSheet
      self.runModalSheetForWindow(NSApp.mainWindow)
   end
   
end


class MEalert

   ##################################################
   #  #mark  ――― CONSTANTS ―――
   ##################################################

   MAX_WIDTH = 2048     # maximum accessory width (arbitrary), will adjust down
   MIN_WIDTH = 285      # the minimum alert accessory width
   MAX_HEIGHT = 500     # maximum accessory height (arbitrary), may adjust down
   MIN_HEIGHT = 25      # a minimum height, based on a single line of text
   INSET = 125          # accessory view inset
   TEXT_HEIGHT = 22     # textfield height
   COMBO_HEIGHT = 25    # combobox height
   BUTTON_HEIGHT = 26   # checkbox/radiobutton height
   PADDING = 11         # padding around checkbox/radiobutton
   RESOURCES = '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/'
   
   # basic (0.0, 0.5, 1.0) set of colors and their inverses (20 + 3 grays)
   COLORS = { 'black' =>  [0.0, 0.0, 0.0],     'white' =>        [1.0, 1.0, 1.0],
              'blue' =>   [0.0, 0.0, 1.0],     'yellow' =>       [1.0, 1.0, 0.0],
              'lime' =>   [0.0, 1.0, 0.0],     'magenta' =>      [1.0, 0.0, 1.0],
              'aqua' =>   [0.0, 1.0, 1.0],     'red' =>          [1.0, 0.0, 0.0],
              'navy' =>   [0.0, 0.0, 0.5],     'lightYellow' =>  [1.0, 1.0, 0.5],
              'green' =>  [0.0, 0.5, 0.0],     'lightMagenta' => [1.0, 0.5, 1.0],
              'teal' =>   [0.0, 0.5, 0.5],     'lightRed' =>     [1.0, 0.5, 0.5],
              'maroon' => [0.5, 0.0, 0.0],     'lightCyan' =>    [0.5, 1.0, 1.0],
              'purple' => [0.5, 0.0, 0.5],     'lightGreen' =>   [0.5, 1.0, 0.5],
              'olive' =>  [0.5, 0.5, 0.0],     'lightBlue' =>    [0.5, 0.5, 1.0],
              'silver' => [0.75, 0.75, 0.75],  'darkGray' =>     [0.25, 0.25, 0.25],
              'gray' =>   [0.5, 0.5, 0.5],     'custom' =>       [0.5, 0.5, 0.5] }  # whatever


   ##################################################
   #  #mark  ――― class methods ―――
   ##################################################

   class << self

      # Simple modal alert dialog with a single OK button.
      def showAlert(infoText = nil, messageText = nil)
         NSAlert.new.tap do |obj|
            obj.messageText = messageText unless messageText.nil?
            obj.informativeText = infoText unless infoText.nil?
         end.runModal
      end


      # Get an NSColor color from a color name.
      # Returns an NSColor (or default/gray if the name is not found).
      # Default control colors used by the class are aliased to support dark mode.
      def getColor(theColor, default = 'gray')
         preset = Proc.new do |color|
            case color
            when 'windowBackground' then return NSColor.windowBackgroundColor  # 0.93
            when 'textColor' then return NSColor.textColor  # 0.0
            when 'backgroundColor' then return NSColor.textBackgroundColor  # 1.0
            when 'clear' then return NSColor.clearColor
            else color
            end
         end
         if preset.call(theColor) == 'box'  # box fill color doesn't have a system color
            dark = !NSAppearance.currentAppearance.name.to_s.index('Dark').nil?
            rgb = dark ? [0.12, 0.12, 0.12] : [0.89, 0.89, 0.89]
         else  # get the specified color or default - no dark mode swaps are performed
            rgb = COLORS[preset.call(default)] if (rgb = COLORS[theColor]).nil?
         end
         rgb = [0.5, 0.5, 0.5] if rgb.nil?   # get gray if nothing else has worked
         NSColor.colorWithSRGBRed( rgb[0],
                            green: rgb[1],
                             blue: rgb[2],
                            alpha: 1.0 )
      end

   end


   ##################################################
   #  #mark  ――― Initialization ―――
   ##################################################

   def initialize(&block)
      @sheet = false  # display the alert as a sheet?
      @delayTime = 0  # a delay time for the give-up timer
      @countdown = 0  # a countdown of the delay time
      @buttonList = []  # this will be a list of button titles
      @accessory = nil  # this will be any accessory view
      @accessoryType = 'textfield'  # can be textfield, combobox, checkbox, or radiobutton
      @coloration = { text: nil, background: nil, border: nil }  # accessory colors - nil will auto select
      @dimensions = { width: nil, height: nil }  # accessory sizes - nil will auto adjust
      @input = nil  # accessory view input item(s)
      @labels = []  # labels (tool tips) for accessory input item(s)
      @placeholder = nil  # placeholder text for the accessory
      @help = nil  # an array of [helpMessageText, helpInformativeText]
      @secure = false  # obscure accessory textField contents? (NSSecureTextField)
      @border = nil  # the border style of the accessory
      @alert = NSAlert.alloc.init  # other NSAlert parameters use the defaults
      @alert.delegate = self
      @alert.window.autorecalculatesKeyViewLoop = true  # hook added views into key-view loop
      instance_eval(&block) if block_given?  # do the meta thing
   end


   ##################################################
   #  #mark ――― Base Alert Methods ―――
   ##################################################

   # Show/display the alert using the current settings.
   # Returns a hash: { button=>(title), reply=>(accessoryView contents, or nil if Cancel) }
   def display
      buttons(['OK']) if @buttonList == []
      makeAccessory unless @accessory
      updateAccessory if @accessory && @accessoryType == 'textfield'
      response = buttonPressed(timer = setTimer)
      timer.invalidate unless timer.nil?
      answer = nil
      case @accessoryType
      when 'textfield', 'combobox'
         answer = @accessory.stringValue.to_s  # handle nil
      when 'checkbox', 'radiobutton'
         answer = {}
         @accessory.contentView.subviews.each { |item| answer[item.title] = item.state }
      end if @accessory
      { button: response, reply: response == 'Cancel' ? nil : answer }
   end
   alias show display


   # (re)set the alert window title
   def title(titleText)
      @alert.window.title = titleText.to_s
   end
   alias title= title


   # (re)set the alert's message text and font
   # Note that although this textField cannot be nil, setting messageText to nil
   # sets the font to a very small size (such as 0.25), which hides it fairly well.
   def message(messageText, messageFont = nil)
      messageFont = NSFont.boldSystemFontOfSize(0.25) if messageText.nil?
      @alert.window.contentView.subviews[4].font = messageFont unless messageFont.nil?
      @alert.messageText = messageText.to_s
   end
   alias message= message


   # (re)set the alert's informative text and font
   # The informative textField doesn't take any space if it isn't set.
   def info(infoText, infoFont = nil)
      @alert.window.contentView.subviews[5].font = infoFont unless infoFont.nil?
      @alert.informativeText = infoText.to_s unless infoText.nil?
   end
   alias info= info


   # (re)set the alert icon
   # Can be the styles 'critical', 'informational', 'warning', the system alert icons
   # 'note', 'stop', other system icons 'caution', 'info', 'tools', 'delete', 'question',
   # or an image file path.
   # Note that the application icon will be used if the specified icon is not valid.
   def icon(iconType)
      theFile = nil
      case type = iconType.to_s.downcase
      when 'critical' then @alert.alertStyle = NSAlertStyleCritical
      when '', 'informational', 'warning'  # default application icon
         @alert.alertStyle = NSAlertStyleInformational  # NSAlertStyleWarning
      when 'note', 'stop' then theFile = "#{RESOURCES}Alert#{type.capitalize}Icon.icns"
      when 'caution' then @alert.icon = NSImage.imageNamed(NSImageNameCaution)
      when 'info' then theFile = "#{RESOURCES}ToolbarInfo.icns"
      when 'tools' then theFile = "#{RESOURCES}ToolbarCustomizeIcon.icns"
      when 'delete' then theFile = "#{RESOURCES}ToolbarDeleteIcon.icns"
      when 'question' then theFile = "#{RESOURCES}GenericQuestionMarkIcon.icns"
      else  theFile = iconType.to_s unless iconType.nil?
      end
      unless theFile.nil?
         candidate = NSImage.alloc.initByReferencingFile(theFile)
         @alert.icon = candidate if candidate.isValid
      end
   end
   alias icon= icon


   # Create buttons from an array of names (left-to-right, bottom-to-top).
   # The parameter 'default' specifies the default button (index).
   # Button names ending with a newline will have the hasDestructiveAction property set.
   # The leftmost or bottom button will have the initial focus.
   def buttons(buttonArray, default = true)
      return if (buttonArray = filterList(buttonArray)).empty? || !@buttonList.empty?
      theButton = nil
      buttonArray.reverse.each do |aButton|  # buttons added right-to-left, top-to-bottom
         destructive = aButton.chomp!  # newline?
         theButton = @alert.addButtonWithTitle(aButton)
         theButton.hasDestructiveAction = true if !destructive.nil? && theButton.respondsToSelector("hasDestructiveAction")
         @buttonList << aButton
         unless default == true  # normal focus, default index as specified
            theButton.keyEquivalent = '' unless aButton == 'Cancel'
            theButton.keyEquivalent = "\r" if default == @buttonList.count - 1
         end
      end
      @alert.window.initialFirstResponder = theButton unless @buttonList.empty?  # last one
      @buttonList
   end
   alias buttons= buttons


   # (re)set the alert dialog give-up time delay (seconds)
   def giveUp(timeDelay)
      @delayTime = timeDelay.abs.to_i
      @timerField = NSTextField.alloc.initWithFrame([[0, 0], [40, 20]])
                               .tap do |obj|  # origin will be set later
         obj.bordered = false
         obj.drawsBackground = false
         obj.font = NSFont.fontWithName('Menlo Bold', size: 12)  # mono-spaced
         obj.editable = false
         obj.selectable = false
         obj.alignment = NSTextAlignmentCenter
         obj.toolTip = 'time remaining'
      end unless defined?(@timerField)
   end
   alias giveUp= giveUp


   # (re)set the alert to show as a sheet over the front window
   def sheet(flag)
      @sheet = (flag == true)
   end
   alias sheet= sheet


   # (re)set the alert help button.
   # The help message and info will be displayed in a sheet over the original alert.
   def help(info, message = nil)
      return if info.nil?
      @alert.showsHelp = true
      @help = [info, message]
   end
   alias help= help


   ##################################################
   #  #mark ――― Alert Delegate Methods ―――
   ##################################################

   # show the alert help sheet using a standard NSAlert
   # If there isn't any message text, the font is made small to reclaim space.
   def alertShowHelp(theAlert)
      info, message = *@help
      helpAlert = NSAlert.alloc.init
      helpAlert.window.contentView.subviews[4]
               .font = NSFont.boldSystemFontOfSize(0.25) if message.nil?
      helpAlert.messageText = message unless message.nil?
		helpAlert.informativeText = info.to_s
		helpAlert.icon = NSImage.alloc.initByReferencingFile("#{RESOURCES}ToolbarInfo.icns")
      helpAlert.beginSheetModalForWindow(theAlert.window, completionHandler: nil)
	   true
   end


   ##################################################
   #  #mark ――― Accessory View Methods ―――
   ##################################################

   # set the type of the accessory view
   # Valid types are 'textfield', 'combobox', 'checkbox', or 'radiobutton'.
   def accessory(type)
      @accessoryType = type.nil? ? nil : type.to_s.downcase
   end
   alias accessory= accessory


   # (re)set the accessory default input items or text
   # Can be a string or an array of strings.
   def input(inputItem)
      @input = inputItem
   end
   alias input= input


   # (re)set accessory labels (tool tips) for input items.
   # Can be a string or array of strings.
   def labels(labelItem)
      @labels = labelItem
   end
   alias labels= labels


   # (re)set the text color to one of the preset names
   # Text color for the message and informational label fields can also be set by
   # including a target ('message', 'informative'), otherwise the accessory is used.
   def textColor(theColor, target = nil)
      return if theColor.nil?
      views = @alert.window.contentView.subviews  # the standard label fields
      case target
      when 'message' then views[4].textColor = MEalert.getColor(theColor, 'textColor')
      when 'informative' then views[5].textColor = MEalert.getColor(theColor, 'textColor')
      else @coloration[:text] = theColor
      end
   end
   alias textColor= textColor


   # (re)set the background color to one of the preset names
   # Background color for the window can also be set by including a target,
   # e.g. ('silver', 'window'), otherwise the accessory is used.
   def backgroundColor(theColor, target = nil)
      return if theColor.nil?
      if target == 'window'
         @alert.window.backgroundColor = MEalert.getColor(theColor, 'windowBackground')
      else  # set the color name for the accessory textField
         @coloration[:background] = theColor
      end
   end
   alias backgroundColor= backgroundColor


   # (re)set the textField/box border color
   def borderColor(theColor)
      return if theColor.nil?
      @coloration[:border] = theColor
   end
   alias borderColor= borderColor


   # (re)set the placeholder text
   def placeholder(placeholderText)
      @placeholder = placeholderText.nil? ? nil : placeholderText.to_s
   end
   alias placeholder= placeholder


   # Set the textField to be secure (obscured characters).
   def secure(flag)
      @secure = (flag == true)
   end
   alias secure= secure


   # Set the accessory border style.
   # Can be 'line', 'color', or 'none', otherwise the default is used.
   def border(borderStyle)
      @border = borderStyle.nil? ? nil : borderStyle.to_s.downcase
   end
   alias border= border


   # Set the width of the accessory, subject to the alert size or MAX_WIDTH.
   def width(accessoryWidth)
      return if accessoryWidth.nil?
      @dimensions[:width] = [accessoryWidth.to_f, MIN_WIDTH, MAX_WIDTH].sort[1]
   end
   alias width= width


   # Set the height of the textField accessory, subject to MIN_HEIGHT or MAX_HEIGHT.
   def height(accessoryHeight)
      return if accessoryHeight.nil?
      @dimensions[:height] = [accessoryHeight.to_f, MIN_HEIGHT, MAX_HEIGHT].sort[1]
   end
   alias height= height


   ##################################################
   #  #mark  ――― Private/Protected Methods ―――
   ##################################################

   private

   # Log if option not found - misspelling, etc.
   def method_missing(symbol, *args, &block)
      NSLog(format('MEalert: %s method not found', symbol))
      super
   end


   # Set the give-up timer.
   def setTimer
      return NSTimer.timerWithTimeInterval( 1.0,
                                    target: self,
                                  selector: 'updateCountdown:',
                                  userInfo: nil,
                                   repeats: true )
                    .tap do |timer|
         @countdown = @delayTime
         @timerField.stringValue = @countdown.to_int.to_s
      end if @delayTime > 1
      nil
   end


   # Update the countdown timer display.
   def updateCountdown(timer)
      @countdown -= 1
      @timerField.stringValue = @countdown.to_int.to_s
      if @countdown <= 0
         @timerField.stringValue = ''
         timer.invalidate
         NSApp.abortModal
      end
   end


   # Get the title of the button pressed, or 'gave up' if timed out.
   def buttonPressed(timer)
      NSRunLoop.mainRunLoop.addTimer(timer, forMode: NSModalPanelRunLoopMode) unless timer.nil?
      response = @sheet && NSApp.mainWindow ? @alert.runModalSheet : @alert.runModal
      response < 0 ? 'gave up' : @buttonList[response - 1000]
   end


   # Update the accessory textField.
   def updateAccessory
      @accessory.stringValue = @input.to_s unless @input.nil?
      @accessory.placeholderString = @placeholder.to_s unless @placeholder.nil?
      @accessory.toolTip = @labels.to_s unless @labels.nil?
      @accessory.textColor = MEalert.getColor(@coloration[:text], 'textColor')
      @accessory.backgroundColor = MEalert.getColor(@coloration[:background], 'backgroundColor')
   end


   # Filter a list for blanks and duplicates.
   # Trailing newlines (indicating set/checked) are chomped for combobox items, chomped
   # after the first one for radiobutton items, and ignored when matching checkbox items.
   def filterList(input)
      set = false
      [*input].each_with_object([]) do |item, output|
        item = item.to_s
        item = item.chomp if (@accessoryType == 'combobox') ||
                             (@accessoryType == 'radiobutton' && set)
        set = true if item.end_with?("\n")
        output << item unless item.empty? || (output & [item, "#{item}\n"]).any?
      end
   end


   ##################################################
   #  #mark ――― Accessory View Creation ―――
   ##################################################

   # Make an accessory view.
   def makeAccessory
      @alert.layout  # layout the alert from current settings (buttons, etc)
      width = @alert.window.frame.size.width - INSET  # default width
      unless @dimensions[:width].nil?
         width = width > @dimensions[:width] ? width : @dimensions[:width] 
      end
      case @accessoryType
      when 'textfield' then textFieldAccessory(width, MAX_HEIGHT)
      when 'combobox' then comboBoxAccessory(width, COMBO_HEIGHT)
      when 'checkbox' then buttonAccessory(width, MAX_HEIGHT, false)
      when 'radiobutton' then buttonAccessory(width, MAX_HEIGHT, true)
      end
      if @delayTime > 1  # set timerField origin
         @alert.layout  # get accessorized layout
         spot = @alert.window.contentView.subviews[0].frame.origin  # icon
         @timerField.frameOrigin = [spot.x + 12, spot.y - 18]
         @alert.window.contentView.addSubview(@timerField)
      end
   end


   # Make a textField accessoryView.
   # The size will auto-adjust for the contents or use the specified height
   # and width settings (the width will not be smaller than the dialog width).
   def textFieldAccessory(width, height)
      return if @input.nil? && @placeholder.nil?  # no textField
      @accessory = NSControl.const_get(@secure ? :NSSecureTextField : :NSTextField)
                            .alloc.initWithFrame([[0, 0], [width, height]])
                            .tap do |text|
         text.font = NSFont.fontWithName('Menlo', size: 13)  # monospaced
      end
      updateAccessory
      @accessory.frameSize = @accessory.cell
                                       .cellSizeForBounds([[0, 0], [width, height]])
                                       .tap do |obj|
         obj.height = @dimensions[:height] unless @dimensions[:height].nil?
         if @dimensions[:width].nil?
            obj.width = width
         else  # adjust for specific width setting
            obj.width = width < @dimensions[:width] ? @dimensions[:width] : width
         end
      end
      setBorder
      @alert.accessoryView = @accessory 
   end


   # Make a comboBox accessoryView - the width will use the specified setting or
   # auto-adjust for the longest input item (the width will not be smaller than the
   # dialog width).
   def comboBoxAccessory(width, height)
      return if (menuList = filterList(@input)).empty?
      @accessory = NSComboBox.alloc
                             .initWithFrame([[0, 0], [width, height]])
                             .tap do |combo|
         combo.completes = true
         combo.cell.lineBreakMode = 5  # NSLineBreakByTruncatingMiddle
         combo.hasVerticalScroller = true
         combo.numberOfVisibleItems = 10  # arbitrary (default is 5)
         comboWidth = width
         combo.toolTip = @labels.to_s
         menuList.each_with_index do |item, index|
            combo.addItemWithObjectValue(item.chomp)
            if @dimensions[:width].nil?
               combo.stringValue = item
               combo.sizeToFit  # kludge to get max width when auto-sizing
               comboWidth = combo.frame.size.width if combo.frame.size.width > comboWidth
               combo.stringValue = ''
            end
         end
         combo.frameSize = [comboWidth + 10, height]  # adjust for contents
         @placeholder = 'Enter text or select an item from the menu' if @placeholder.nil?
         combo.placeholderString = @placeholder
      end
      setBorder
      @alert.accessoryView = @accessory
   end


   # Make a checkBox or radioButton accessoryView - the width will use the specified setting
   # or auto-adjust for the longest input item (the width will not be smaller than the
   # dialog width), and the height will always auto-adjust for the number of items.
   def buttonAccessory(width, height, radio = false)
      return if (buttonList = filterList(@input)).empty?
      height = buttonList.length * BUTTON_HEIGHT
      @accessory = NSBox.alloc
                        .initWithFrame([[0, 0], [width, height]])
                        .tap do |box|
         box.titlePosition = 0
         buttonWidth = width
         buttonList.each_with_index do |item, index|
            button = makeButton(radio, item)
            button.frame = [[0, height - (index + 1) * BUTTON_HEIGHT], [width, MIN_HEIGHT]]
            button.toolTip = @labels[index]
            if @dimensions[:width].nil?
               button.sizeToFit  # use full width only when auto-sizing
               buttonWidth = button.frame.size.width + 10 if button.frame.size.width > buttonWidth
            end
            box.addSubview(button)
         end
         adjustment = @sheet ? PADDING : (PADDING / 2) + 1  # sheet vs window
         box.frameSize = [buttonWidth + 10, height + adjustment]  # adjust box for contents
      end
      setBorder
      @alert.accessoryView = @accessory
   end


   # Make an individual button for the buttonAccessory.
   # Button titles ending with a newline will be set/checked (button title is chomped).
   def makeButton(radio, item)
      if radio
         NSButton.radioButtonWithTitle('', target: self, action: 'buttonAction:')
      else
         NSButton.checkboxWithTitle('', target: self, action: 'buttonAction:')
      end.tap do |button|
         button.lineBreakMode = 5  # NSLineBreakByTruncatingMiddle
         button.state = NSOnState if item.end_with?("\n")  # NSControlStateValueOn
         button.title = item.chomp
      end
   end


   # Button action method.
   def buttonAction(sender)
      # nothing (yet)
   end


   # Set the border style.
   # A 'color' style is the same as bordered, but using the color set with borderColor.
   # Default box is no border with light gray fill, textField is bezeled border.
   def setBorder
      return if @border.nil?  # default
      if @accessory.class == NSBox
         @accessory.boxType = NSBoxCustom
         @accessory.cornerRadius = 5.0
         case @border
         when 'none'  # no border or fill color
            @accessory.borderType = NSNoBorder
         when 'line', 'color'  # line border with gray fill
            @accessory.borderType = NSLineBorder
            @accessory.fillColor = MEalert.getColor 'box'
            setBorderColor if @border == 'color'
         end
      else # NSTextField or NSComboBox
         textField = (@accessory.class == NSTextField)
         case @border
         when 'none'
            textField ? @accessory.bordered = false : @accessory.buttonBordered = false
            @accessory.bezeled = false
         when 'line', 'color'
            textField ? @accessory.bordered = false : @accessory.buttonBordered = false
            setBorderColor if @border == 'color'
         end
      end
   end


   # Set the accessory border color.
   def setBorderColor
      return if @coloration[:border].nil?
      @accessory.wantsLayer = true
      @accessory.layer.borderColor = MEalert.getColor(@coloration[:border]).CGColor  # QuartzCore
      @accessory.layer.borderWidth = 1
   end

end

