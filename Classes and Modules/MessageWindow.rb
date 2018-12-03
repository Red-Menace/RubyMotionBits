#
#  MessageWindow.rb
#
#  Created by Red_Menace on 03-19-14, last updated/reviewed on 12-03-18
#  Copyright (c) 2014-2018 Menace Enterprises, red_menace|at|menace-enterprises|dot|com
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
#  This class is a controller for a message window.  The window consists of a
#  scrolling text view, with an icon and multiple line label text field above it.
#  The default icon and window title are those of the application (the icon is
#  assumed to have a file extension of 'icns' with the name in the CFBundleIconFile
#  Info.plist key - change the setIcon method to match the Rakefile if necessary).
#  The message text view uses a mono-spaced font (default) to preserve shell script
#  output formatting.
#
#  The message window is not a modal dialog or alert, and does not auto-resize
#  around its contents - the default settings provide a scrolling text view that
#  shows approximately 80 characters by 24 lines (including any scrollbars).
#
#  The window is resizable, and also includes a progress spinner in the titlebar.
#
#  Note that the initialization of each instance just creates a default message
#  window object, so that changes to properties or other desired setup (preloading
#  the text view, window location, etc.) can be made before showing the window.
#
#  Instance Methods:
#     init - standard initialization (also .new)
#     initWithWrapping - initialize with a wrapping text view
#     setup(parameters = {}) - set up the message window
#     setTitle(titleText) - (re)set the window title
#     setIcon(theIcon) - (re)set the message icon
#     setLabel(labelText) - (re)set the message label textField
#     setMessage(messageText, scroll = true) - (re)set the message textView
#     addText(parameters = {}) - add text to the message textView
#     setSpinner() - (re)set the animation of the progress indicator
#
#  Frequently used methods from parent classes:
#     window.visible? - is the window visible?
#     showWindow(sender) - show the window
#     close - close the window
#     (NSWindow).windowController - get the controller instance for a window
#  The individual UI objects and userInfo ivars are also exposed in the accessors.
#
#  Typical usage:
#     initialize controller via Cocoa's alloc.init (or .new)
#     perform setup
#     set or adjust other parameters as desired
#     show the message window
#     dismiss the window when completed
#


class MessageWindow < NSWindowController

   ##################################################
   # #mark ―――― CONSTANTS ――――
   ##################################################

   WINDOW_RECT = [[400, 600], [621, 461]]  # main window location and size (~ 80 x 24)
   WINDOW_MIN_SIZE =          [335, 250]   # minimum window size (~ 40 x 10)
   IMAGE_FRAME = [[20, 393], [48, 48]]     # icon imageView frame
   LABEL_FRAME = [[80, 393], [524, 48]]    # label frame when using an icon image
   LABEL_OFFSET = 60                       # label offset when not using icon
   TEXTVIEW_FRAME = [[20, 20], [581, 353]] # also used for the scroll view


   ##################################################
   # #mark ―――― Attributes ――――
   ##################################################

   # 'window' is already defined by the controller
   attr_reader :labelField    # the label text field
   attr_reader :imageView     # for a small icon image
   attr_reader :textView      # the main text view
   attr_reader :scrollView    # contains the text view
   attr_reader :title         # the title of the message window
   attr_reader :iconPath      # path for the icon, if using contents of a file
   attr_reader :spinner       # title bar progress indicator
   attr_accessor :userInfo    # miscellaneous controller information (file path, etc)


   ##################################################
   # #mark ―――― Initialization ――――
   ##################################################

   # create a default message window
   # MessageWindowController.alloc.init (or .new)  #=> windowController
   def init
      @wrapping = false
      initWithWindow(nil)
   end


   # create a message window with a wrapping text view
   #  MessageWindowController.alloc.initWithWrapping  #=> windowController
   def initWithWrapping
      @wrapping = true
      initWithWindow(nil)
   end


   # base NSWindowController initialization
   def initWithWindow(window)
      super
      @wrapping ||= false # normally set in init methods
      return nil unless createMessageWindow # problem creating window
      @userInfo = nil
      setTitle('default') # default title for basic window
      setIcon('default') # default icon for basic window
      self
   end


   ##################################################
   # #mark  ―――― Instance Methods ――――
   ##################################################

   # set up a message window - items are only updated if parameters provided
   # the message text can be an attributed string
   # Returns true if successful, false otherwise.
   def setup(parameters = {})
      options = { messageText: nil,  # the message text
                  labelText: nil,    # text for a label above the message
                  titleText: nil,    # the window title
                  icon: nil          # an icon next to the label
                }.merge(parameters)
      setTitle(options[:titleText]) unless options[:titleText].nil?
      setIcon(options[:icon]) unless options[:icon].nil?
      if options[:messageText].class.to_s.end_with?('AttributedString')
         @textView.attributedString = options[:messageText] unless options[:messageText].nil?
      else  # regular string
         @textView.string = options[:messageText] unless options[:messageText].nil?
      end
      @labelField.stringValue = options[:labelText].to_s unless options[:labelText].nil?
      true  # success
   rescue StandardError => error
      p "Error in MessageWindow's setup method: " + error.message
      false
   end


   # (re)set the title of the message window
   # A title text of 'default' will use the application name.
   # Returns the new window title.
   def setTitle(titleText)
      self.window.title = checkParameter(titleText) do
         NSBundle.mainBundle.infoDictionary['CFBundleName']  # default
      end
      @title = self.window.title
   end

   alias title= setTitle


   # (re)set the message icon to an NSImage or the contents of a file
   # The icon can be an NSImage, a file path to an icon resource, the text 'default'
   # for the application icon, or nil/false for nothing. The label text field will
   # reclaim the icon space if it is not used.
   # Returns the new icon file path (or '' if none).
   def setIcon(theIcon)
      currentOrigin = @labelField.frame.origin.to_a
      if theIcon.class == NSImage  # set image directly
         adjustFrame(LABEL_OFFSET) if currentOrigin[0] != LABEL_FRAME[0][0]
         @imageView.image = theIcon
         iconFilePath = ''
      else  # set image to the specified file - 'default' is the application icon
         if (iconFilePath = checkParameter(theIcon) do
                  appIcon = NSBundle.mainBundle.infoDictionary['CFBundleIconFile']
                  NSBundle.mainBundle.pathForResource(appIcon, ofType: 'icns')  # default
            end)
            adjustFrame(LABEL_OFFSET) if currentOrigin[0] != LABEL_FRAME[0][0]
            @imageView.image = NSImage.alloc.initWithContentsOfFile iconFilePath
         else
            @imageView.image = nil
            iconFilePath = ''
            adjustFrame(-LABEL_OFFSET) if currentOrigin[0] == LABEL_FRAME[0][0]
         end
      end
      @iconPath = iconFilePath
   end

   alias icon= setIcon


   # (re)set the contents of the message label textField
   # Returns the new label textField contents.
   def setLabel(labelText)
      @labelField.stringValue = labelText.to_s
   end

   alias label= setLabel


   # (re)set the contents of the message textView
   # the message text can be an attributed string
   # Returns the new message textView contents.
   def setMessage(messageText, scroll = true)
      if messageText.class.to_s.end_with?('AttributedString')
         @textView.attributedString = messageText
         @textView.scrollRangeToVisible [messageText.to_s.length, 0] if scroll
         @textView.attributedString
      else  # regular string
         @textView.string = messageText
         @textView.scrollRangeToVisible [messageText.to_s.length, 0] if scroll
         @textView.string
      end
   end

   alias message= setMessage


   # add text to the message textView, using default parameters as needed
   # text can be an attributed string
   # Returns the new message textView contents.
   def addText(parameters = {})
      options = { text: '',         # the text to add
                  index: -1,        # where to add it (beginning=0, ending=-1, etc)
                  scroll: 'true'    # scroll to show added text?
                }.merge(parameters)
      someIndex = options[:index].to_i
      someText = options[:text]
      if someText.class.to_s.end_with?('AttributedString')
         unless someIndex.abs > @textView.attributedString.length || someText == ''  # nothing to add
            someIndex = @textView.attributedString.length + someIndex + 1 if someIndex < 0
            scrollFlag = %w[true yes 1].include?(options[:scroll].to_s.downcase)
            @textView.replaceCharactersInRange([someIndex, 0], withAttributedString: someText)
            @textView.scrollRangeToVisible [someIndex, someText.length] if scrollFlag
         end
         @textView.attributedString
      else  # regular string
         unless someIndex.abs > @textView.string.length || someText == ''  # nothing to add
            someIndex = @textView.string.length + someIndex + 1 if someIndex < 0
            scrollFlag = %w[true yes 1].include?(options[:scroll].to_s.downcase)
            @textView.replaceCharactersInRange([someIndex, 0], withString: someText)
            @textView.scrollRangeToVisible [someIndex, someText.length] if scrollFlag
         end
         @textView.string
      end
   end


   # (re)set the animation of the progress indicator
   def setSpinner(flag)
      switch(flag) ? @spinner.startAnimation(self) : @spinner.stopAnimation(self)
   end

   alias spinner= setSpinner


   ##################################################
   # #mark  ―――― Private/Protected Methods ――――
   ##################################################

   private

   # check for 'empty' or default parameter
   # Returns nil for a false-ish value, the block if 'default', otherwise the value.
   def checkParameter(value)
      if %W['' none false #{nil} null 0].include?(value.to_s.downcase)
         nil
      elsif value.to_s.downcase == 'default'
         block_given? ? yield : value
      else
         value
      end
   end


   # check for true- or false-ish parameter
   # returns true/false from switch settings (e.g. yes/no, on/off, etc) otherwise nil
   def switch(value)
      return true if %W[true on yes start begin 1].include?(value.to_s.downcase)
      return false if %W[false off no stop end 0].include?(value.to_s.downcase)
      nil
   end


   # create the message window and its UI objects
   # Returns true if successful, false otherwise.
   def createMessageWindow
      return true if @setup  # already created
      raise unless createWindow
      self.window.delegate = NSApp.delegate  # windowWillClose, etc
      self.window.windowController = self
      self.window.addTitlebarAccessoryViewController(createTitlebar)
      [createImageView, createLabel, createTextView].each do |view|
         self.window.contentView.addSubview(view) if view
      end
      self.window.makeFirstResponder @spinner  # get focus off the imageView
      @setup = true
   rescue StandardError => error
      @setup = false
      errorString = "Error in MessageWindow's createMessageWindow method: "
      if error.class == NSException
         errorString += error.reason
      else
         errorString += error.message
      end
      NSLog(errorString)  # Terminal and Console
   end


   # Returns true if window setup is complete.
   def createWindow
      windowMask = NSTitledWindowMask |
                   NSClosableWindowMask |
                   NSMiniaturizableWindowMask |
                   NSResizableWindowMask
      self.window = NSWindow.alloc
                            .initWithContentRect( WINDOW_RECT,
                                       styleMask: windowMask,
                                         backing: NSBackingStoreBuffered,
                                           defer: true)
      self.window.contentMinSize = WINDOW_MIN_SIZE
      self.window.preventsApplicationTerminationWhenModal = false
      self.window.releasedWhenClosed = false  # so window can be shown again
      self.window.level = NSNormalWindowLevel  # NSFloatingWindowLevel
      self.window.allowsConcurrentViewDrawing = true
      self.window.hasShadow = true
   end


   # Returns a title bar accessory view containing a spinning progress indicator.
   def createTitlebar
      height = NSHeight(self.window.frame) - NSHeight(self.window.contentView.frame)
      @spinner = NSProgressIndicator.alloc
                                    .initWithFrame([[0, 2], [height - 4, height - 4]])
                                    .tap do |obj|
         obj.usesThreadedAnimation = true
         obj.indeterminate = true
         obj.style = NSProgressIndicatorSpinningStyle
         obj.displayedWhenStopped = false
      end
      titlebarView = NSView.alloc.initWithFrame([[0, 0], [40, height]])
      titlebarView.addSubview(@spinner)
      NSTitlebarAccessoryViewController.alloc.init.tap do |obj|
         obj.view = titlebarView
         obj.layoutAttribute = NSLayoutAttributeRight
      end
   end


   # Returns the imageView object for addition to the window content.
   def createImageView
      @imageView = NSImageView.alloc.initWithFrame(IMAGE_FRAME).tap do |obj|
         obj.autoresizingMask = NSViewMinYMargin
         obj.imageScaling = NSScaleToFit  # NSScaleProportionally
         obj.editable = true
      end
   end


   # Returns the label object for addition to the window content.
   def createLabel
      @labelField = NSTextField.alloc.initWithFrame(LABEL_FRAME).tap do |obj|
         obj.autoresizingMask = NSViewWidthSizable |
                                NSViewMinYMargin
         obj.bordered = false
         obj.drawsBackground = false
         obj.font = NSFont.boldSystemFontOfSize 12  # systemFontOfSize 13
         obj.editable = false
         obj.selectable = true
         obj.cell.alignment = NSNaturalTextAlignment
         obj.cell.lineBreakMode = NSLineBreakByWordWrapping  # NSLineBreakByCharWrapping
      end
   end


   # adjust the label frame for an icon - +offset applied to origin, -offset to width
   # Returns the new frame.
   def adjustFrame(offset)
      currentFrame = @labelField.frame
      currentFrame[0][0] += offset  # add offset (+/-) to origin
      currentFrame[1][0] -= offset  # opposite for width
      @labelField.frame = currentFrame
   end


   # Returns the textView/scrollView object for addition to the window content.
   def createTextView
      @textView = NSTextView.alloc.initWithFrame TEXTVIEW_FRAME
      @textView.autoresizingMask = NSViewWidthSizable  # for wrapping view
      # use mono spaced fonts such as Ayuthaya, [Andale Mono, Menlo], Monaco, Courier
      @textView.font = NSFont.fontWithName('Menlo', size: 12)
      @textView.maxSize = [1.0E+5, 1.0E+5]  # set big enough to handle really long lines
      @textView.editable = true
      @textView.selectable = true
      @textView.allowsUndo = true
      @textView.horizontallyResizable = !@wrapping  # false for wrapping text
      @textView.verticallyResizable = true
      setupTextContainer
      createScrollView
   end


   def setupTextContainer
      @textView.textContainer.containerSize = [1.0E+5, 1.0E+5]  # same as @textView.maxSize
      @textView.textContainer.widthTracksTextView = @wrapping  # true for wrapping text
      @textView.textContainer.heightTracksTextView = false
      @textView.textContainer.lineFragmentPadding = (@wrapping ? 12.0 : 3.0)
   end


   # Returns the scrollView.
   def createScrollView
      @scrollView = NSScrollView.alloc.initWithFrame(TEXTVIEW_FRAME).tap do |obj|
         obj.autoresizingMask = NSViewWidthSizable |
                                NSViewMaxXMargin |
                                NSViewHeightSizable
         obj.borderType = NSBezelBorder
         obj.hasVerticalScroller = true
         obj.hasHorizontalScroller = true
         obj.autohidesScrollers = true
         obj.documentView = @textView
      end
   end

end

