module FaceCrop
    
  # Detector
  #
  module Detector
    
    autoload :FaceCom, File.expand_path('../detectors/face_com', __FILE__)
    autoload :OpenCV, File.expand_path('../detectors/opencv', __FILE__)
    
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
      def detect(file)
        puts file
        key = "#{self.class}:" + Digest::MD5.hexdigest(File.read(file))
        
        regions = FaceCrop::Detector::Cache[key] 
        return regions unless regions.nil?

        regions = detect_faces(file)
        FaceCrop::Detector::Cache[key] = regions        
        regions
      end
      
    end
    
    class Cache
      @@cache = {}
      
      def self.[]=(key, faces)
        @@cache[key] = faces
      end
      
      def self.[](key)
        @@cache[key]
      end
      
      def self.clear
        @@cache = {}
      end
    end
    
    # Region
    #
    class Region
      attr_accessor :center
      attr_accessor :width
      attr_accessor :height      
      attr_accessor :color  
      
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
    
    # Point
    #
    class Point
      attr_accessor :x
      attr_accessor :y
      def initialize(x,y)
        @x, @y = x, y
      end
    end
  end
end