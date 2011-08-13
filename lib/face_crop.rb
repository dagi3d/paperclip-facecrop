require 'ostruct'
module FaceCrop
  
  
  # Detector
  #
  module Detector
    
    # Base
    #
    class Base
      # initialize
      #
      def initialize(options)
        @options = options
      end
      
      # detect
      #
      def detect(image)
        
      end
    end
    
    class Region
      attr_accessor :center
      attr_accessor :width
      attr_accessor :height        
      
      def initialize(x, y, width, height)
        @width, @height = width, height
        @center = Point.new(x, y)
      end
      
      def top_left
        @top_left ||= Point.new(@center.x - (width / 2), @center.y - (height / 2))
      end
      
      def bottom_right
        @bottom_right ||= Point.new(@center.x + (width / 2), @center.y + (height / 2))
      end
      
      def to_s
        "#{center.x},#{center.y}-#{width}x#{height}"
      end
    end
    
    class Point
      attr_accessor :x
      attr_accessor :y
      def initialize(x,y)
        @x, @y = x, y
      end
    end
  end
end