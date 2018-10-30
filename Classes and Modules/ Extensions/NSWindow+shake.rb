
class NSWindow

   # Provide a shake animation (left/right, as in 'no').
   def shake
      shakes, duration, amount, friskiness = 3, 0.5, 300, 0.025
      
      frame = self.frame
      minX, minY = NSMinX(frame), NSMinY(frame)  # lower left corner
      
      animation = CAKeyframeAnimation.animation
      path = CGPathCreateMutable()
      CGPathMoveToPoint(path, nil, minX, minY)  # start
      shakes.times do
         CGPathAddLineToPoint(path, nil, minX - amount * friskiness, minY)  # left
         CGPathAddLineToPoint(path, nil, minX + amount * friskiness, minY)  # right
      end
      CGPathCloseSubpath(path)  # finish
      animation.path = path
      animation.duration = duration
   
      self.animations = {'frameOrigin' => animation}
      self.animator.frameOrigin = self.frame.origin
   end

end


