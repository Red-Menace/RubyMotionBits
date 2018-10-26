
#
#  FlipController.rb
#
#  Created by Red_Menace on 01-06-14, last updated/reviewed on 05-25-18
#  Copyright (c) 2014-2018 Menace Enterprises, red_menace|at|menace-enterprises|dot|com
#
#  This module provides classes and extensions for flip animation between two NSViews.
#  If using resizable views, don't forget to keep the backing view the same size.
#
#  Based on a project by Drew McCormack (public domain 2010, no longer available)
#


module Flipper

   ##################################################
   #  #mark  ―――― Class Extensions ――――
   ##################################################

   class CAAnimation

      def self.flipAnimationWithDuration( aDuration,
                  forLayerBeginningOnTop: beginsOnTop,
                             aroundXAxis: xAxis,
                             scaleFactor: scaleFactor)
         # rotating halfway (pi radians) around X or Y axis gives the appearance of flipping
         keyValue = xAxis ? 'transform.rotation.x' : 'transform.rotation.y'
         startValue = beginsOnTop ? 0.0 : 3.14159265359
         endValue = beginsOnTop ? -3.14159265359 : 0.0
         flipAnimation = CABasicAnimation.animationWithKeyPath(keyValue).tap do |obj|
            obj.fromValue = NSNumber.numberWithDouble(startValue)
            obj.toValue = NSNumber.numberWithDouble(endValue)
         end
         # view moves "in" < scale of 1.0 is flat > view moves "out"
         shrinkAnimation = CABasicAnimation.animationWithKeyPath('transform.scale').tap do |obj|
            obj.toValue = NSNumber.numberWithFloat(scaleFactor)
            # only have to animate shrink in one direction, then use autoreverse to grow
            obj.duration = aDuration * 0.50
            obj.autoreverses = true
         end
         # combine flipping and shrinking into one smooth animation
         animationGroup = CAAnimationGroup.animation.tap do |obj|
            obj.animations = [flipAnimation, shrinkAnimation]
            # as edge gets "closer", it appears to move faster - simulate with an easing function
            obj.timingFunction = CAMediaTimingFunction.functionWithName(KCAMediaTimingFunctionEaseInEaseOut)
            obj.duration = aDuration
            # to avoid flicker, hold animated view until we can fix it
            obj.fillMode = KCAFillModeForwards
            obj.removedOnCompletion = false
         end
      end

   end


   class NSView

      def layerFromContents
         CALayer.layer.tap do |obj|
            obj.bounds = self.bounds
            bitmapRep = self.bitmapImageRepForCachingDisplayInRect(self.bounds)
            self.cacheDisplayInRect(self.bounds, toBitmapImageRep: bitmapRep)
            obj.contents = bitmapRep.CGImage
         end
      end

   end


   ##################################################
   #  #mark  ――――  Module Classes ――――
   ##################################################

   class FlipController

      attr_accessor :fromTopLeft    # direction of the flip
      attr_accessor :xAxis          # axis of the flip
      attr_accessor :scale          # flip in < 1.0 > flip out scale
      attr_accessor :duration       # speed of flip

      attr_reader :isFlipped        # is image flipped?
      attr_reader :isDone           # is animation completed?


      def initialize(newHostView, newFrontView, newBackView)
         @hostView = newHostView    # the view containing the others (for clipping)
         @frontView = newFrontView  # the visible view in front
         @backView = newBackView    # a hidden view containing the image to flip to

         @fromTopLeft = true
         @xAxis = false
         @scale = 2.0
         @duration = 1.2

         @isFlipped = false
         @isDone = true
      end


      def flip(sender)  # do some flippin'
         @isDone = false
         if @isFlipped
            @topView, @bottomView = @backView, @frontView
         else
            @topView, @bottomView = @frontView, @backView
         end

         topAnimation = CAAnimation.flipAnimationWithDuration( @duration,
                                       forLayerBeginningOnTop: true,
                                                  aroundXAxis: @xAxis,
                                                  scaleFactor: @scale)
         bottomAnimation = CAAnimation.flipAnimationWithDuration( @duration,
                                          forLayerBeginningOnTop: false,
                                                     aroundXAxis: @xAxis,
                                                     scaleFactor: @scale)
         @bottomView.frame = @topView.frame
         @topLayer, @bottomLayer = @topView.layerFromContents, @bottomView.layerFromContents

         perspective = CATransform3DIdentity
         zDistance = 1500.0
         perspective.m34 = @fromTopLeft ? 1.0 / zDistance : -1.0 / zDistance
         @topLayer.transform, @bottomLayer.transform = perspective, perspective

         [@topLayer, @bottomLayer].each do |layer|
            layer.frame = @topView.frame
            layer.doubleSided = false
            @hostView.layer.addSublayer(layer)
         end

         CATransaction.begin
         CATransaction.setValue(NSNumber.numberWithBool(true), forKey: KCATransactionDisableActions)
         @topView.removeFromSuperview
         CATransaction.commit

         topAnimation.delegate = self
         CATransaction.begin
         @topLayer.addAnimation(topAnimation, forKey: 'flip')
         @bottomLayer.addAnimation(bottomAnimation, forKey: 'flip')
         CATransaction.commit
      end


      def animationDidStop(animation, finished: flag)  # animation callback
         CATransaction.begin
         CATransaction.setValue(NSNumber.numberWithBool(true), forKey: KCATransactionDisableActions)
         @hostView.addSubview(@bottomView)
         [@topLayer, @bottomLayer].each do |layer|
            layer.removeFromSuperlayer
            layer = nil
         end
         CATransaction.commit
         @isFlipped = !@isFlipped
         @isDone = true
      end


      def visibleView  # get the view that is currently visible
         @isFlipped ? @backView : @frontView
      end

   end

end

