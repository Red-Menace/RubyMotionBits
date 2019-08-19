#
#  MessageWindow.rb
#
#  Created by Red_Menace on 03-19-14, last updated/reviewed on 08-19-19
#  Copyright (c) 2014-2019 Menace Enterprises, red_menace|at|menace-enterprises|dot|com
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
#  Info.plist key).
#
#  The message text view uses a mono-spaced font (default) to preserve shell script
#  output formatting, but can be edited and will accept attributed strings.
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
#     initWithWrapping - initialize with a wrapping textView
#     setup(parameters = {}) - set up the message window
#     setTitle(titleText) - (re)set the window title
#     setIcon(theIcon) - (re)set the message icon
#     setLabel(labelText) - (re)set the message label textField
#     setMessage(messageText, scroll = true) - (re)set the message textView
#     addText(parameters = {}) - add text to the message textView
#     setSpinner(term) - (re)set the animation of the progress indicator
#     setWrapMode(term) - (re)set the textView wrapping mode
#
#  Frequently used methods from parent classes:
#     window.visible? - is the window visible?
#     showWindow(sender) - show the window
#     close - close the window
#     (NSWindow).windowController - get the controller instance for a window
#  Various UI objects and userInfo ivars are also exposed in the accessors.
#
#  Typical usage:
#     initialize controller via Cocoa's alloc.init (or .new)
#     perform setup
#     set or adjust other parameters as desired
#     show the message window
#     dismiss the window when completed
#
#
# Terms to search for if localizing:
#     "Error in MessageWindow's setup method: "
#     "Error in MessageWindow's createMessageWindow method: "
#


class MessageWindow < NSWindowController

   ##################################################
   # #mark ―――― CONSTANTS ――――
   ##################################################

   V_SHIFT = 0    # subview shift from standard height (+/- 250)
   H_SHIFT = 0    # subview shift from standard width (+/- 300)
   WINDOW_RECT = [[400, 600], [621 + H_SHIFT, 461 + V_SHIFT]]  # standard (~ 80 x 24)
   WINDOW_MIN_SIZE =          [371, 181]                       # minimum (~ 45 x 5)
   IMAGE_FRAME = [[20, 393 + V_SHIFT], [48, 48]]               # icon imageView
   LABEL_FRAME = [[80, 393 + V_SHIFT], [524 + H_SHIFT, 48]]    # frame when using an icon
   LABEL_OFFSET = 60                                           # offset when not using icon
   TEXTVIEW_FRAME = [[20, 20], [581 + H_SHIFT, 353 + V_SHIFT]] # also for the scroll view


   ##################################################
   # #mark ―――― Attributes ――――
   ##################################################

   # 'window' is already defined by the controller
   attr_reader :labelField    # the label textField
   attr_reader :imageView     # for a small icon image
   attr_reader :textView      # the main textView
   attr_reader :title         # the title of the message window
   attr_reader :iconPath      # path for the icon, if using contents of a file
   attr_accessor :userInfo    # miscellaneous controller information (file path, etc)
   attr_accessor :wrapping    # textView wrapping mode


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
         @textView.textStorage.attributedString = options[:messageText] unless options[:messageText].nil?
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
            @imageView.image = NSImage.alloc.initWithContentsOfFile(iconFilePath)
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


   # (re)set the contents of the message textView - can be an attributed string
   # Returns the new textView string.
   def setMessage(messageText, scroll = true)
      if messageText.class.to_s.end_with?('AttributedString')
         @textView.textStorage.attributedString = messageText
      else  # regular string
         @textView.string = messageText
      end
      scrolling = %w[true yes 1].include?(scroll.to_s.downcase)
      @textView.scrollRangeToVisible([messageText.to_s.length, 0]) if scrolling
      @textView.string
   end
   alias message= setMessage


   # add text to the message textView - can be an attributed string
   # Returns the new textView string.
   def addText(parameters = {})
      options = { text: '',         # the text to add
                  index: -1,        # where to add it (beginning=0, ending=-1, etc)
                  scroll: 'false'   # scroll to show added text?
                }.merge(parameters)
      someText = options[:text]
      someIndex = options[:index].to_i
      someIndex = @textView.string.length + someIndex + 1 if someIndex < 0
      unless someIndex > @textView.string.length || someText == ''  # nothing to add
         if someText.class.to_s.end_with?('AttributedString')
            @textView.textStorage.replaceCharactersInRange( [someIndex, 0],
                                      withAttributedString: someText)
         else  # regular string
            @textView.replaceCharactersInRange( [someIndex, 0],
                                    withString: someText)
         end
         scrolling = %w[true yes 1].include?(options[:scroll].to_s.downcase)
         @textView.scrollRangeToVisible([someIndex, someText.length]) if scrolling
      end
      @textView.string
   end


   # (re)set the animation of the progress indicator
   def setSpinner(term)
      return if (mode = switch?(term)).nil?
      mode ? @spinner.startAnimation(self) : @spinner.stopAnimation(self)
   end
   alias spinner= setSpinner


   # (re)set text wrapping mode.
   def setWrapMode(term)
      return if (mode = switch?(term)).nil?
      if mode  # wrap at textView width
         layoutSize = NSMakeSize(@textView.enclosingScrollView.contentSize.width, 1.0E+4)
         @textView.enclosingScrollView.hasHorizontalScroller = false
         @textView.textContainer.widthTracksTextView = true
      else  # no wrapping
         layoutSize = NSMakeSize(1.0E+4, 1.0E+4)
         @textView.maxSize = layoutSize
         @textView.enclosingScrollView.hasHorizontalScroller = true
         @textView.textContainer.widthTracksTextView = false
      end
      @textView.textContainer.containerSize = layoutSize
      @textView.textContainer.lineFragmentPadding = (mode ? 12.0 : 3.0)
      @textView.enclosingScrollView.needsDisplay = true
      @wrapping = mode
   end
   alias wrapMode= setWrapMode


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


   # Check for a match with switch values (yes/no, on/off, etc).
   # Returns true/false if argument matches a switch, otherwise nil.
   def switch?(value)
      return true if %W[true on yes start begin 1].include?(value.to_s.downcase)
      return false if %W[false off no stop end 0].include?(value.to_s.downcase)
      nil
   end


   # create the message window and its UI objects
   # Returns true if successful, false otherwise.
   def createMessageWindow
      return true if @done  # already created
      raise unless createWindow
      self.window.delegate = NSApp.delegate  # windowWillClose, etc
      self.window.windowController = self
      self.window.addTitlebarAccessoryViewController(createTitlebar)
      [createImageView, createLabel, createTextView].each do |view|
         self.window.contentView.addSubview(view) if view
      end
      setWrapMode(@wrapping)
      self.window.makeFirstResponder(@spinner)  # get focus off the imageView
      @done = true
   rescue StandardError => error
      @done = false
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
         obj.font = NSFont.boldSystemFontOfSize(12)  # systemFontOfSize 13
         obj.editable = false
         obj.selectable = true
         obj.cell.alignment = NSNaturalTextAlignment
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
      @textView = NSTextView.alloc.initWithFrame(TEXTVIEW_FRAME)
      @textView.autoresizingMask = NSViewWidthSizable  # for wrapping view
      @textView.horizontallyResizable = true
      @textView.editable = true
      @textView.selectable = true
      @textView.allowsUndo = true
      @textView.usesFontPanel = true  # sync with the system font panel
      @textView.usesFindPanel = true
      setAttributes
      createScrollView
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


   # Set text view attributes (tab stops, font, etc).
   def setAttributes
      attrString = NSMutableAttributedString.alloc.initWithString(' ')
      paraStyle = NSMutableParagraphStyle.alloc.init
      tabArray = NSMutableArray.array
      (1..21).each do |index|  # add a few more tab stops
         tabArray.addObject(NSTextTab.alloc.initWithType( NSLeftTabStopType,
                                                location: index * 27.0))
      end
      paraStyle.tabStops = tabArray
      attrString.addAttribute( NSParagraphStyleAttributeName,
                        value: paraStyle,
                        range: NSMakeRange(0, attrString.length))
      # Use mono spaced fonts such as Ayuthaya, [Andale Mono, Menlo], Monaco, Courier
      attrString.addAttribute( NSFontAttributeName,
                        value: NSFont.fontWithName('Menlo', size: 12),
                        range: NSMakeRange(0, attrString.length))
      @textView.textStorage.attributedString = attrString
   end

end

