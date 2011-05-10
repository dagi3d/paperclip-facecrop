require 'opencv_ext'

module Paperclip
  class FaceCrop < Paperclip::Thumbnail

    @@debug = false
  
    cattr_accessor :classifiers
    cattr_accessor :debug
  
    def initialize(file, options = {}, attachment = nil)
      super(file, options, attachment)
    
      faces_regions = []
      faces_parts_regions = []
        
      raise "No classifiers were defined" if self.classifiers.nil?
    
      image = OpenCV::IplImage.load(file.path, 1)
    
      faces_regions = detect_regions(image, self.classifiers[:face])
    
      #Paperclip::FaceCrop.classifiers[:nose]
      unless self.classifiers[:parts].nil?
        faces_parts_regions = detect_regions(image, self.classifiers[:parts], OpenCV::CvColor::Red)
      
        faces_regions.reject! do |face_region|
          region = faces_parts_regions.detect do |part_region|
            face_region.collide?(part_region)
          end
        
          region.nil?
        end
      end
    
      x_coords = []
      y_coords = []
      widths   = []
      heights  = []
    
      faces_regions.each do |region|
        x_coords << region.top_left.x << region.bottom_right.x
        y_coords << region.top_left.y << region.bottom_right.y
        widths << region.width
        heights << region.height
      end
    
      @has_faces = faces_regions.size > 0
     
      if @has_faces
        @top_left_x = x_coords.min
        @top_left_y = y_coords.min
        @bottom_right_x = x_coords.max
        @bottom_right_y = y_coords.max
      
        # average faces areas
        average_face_width  = widths.sum / widths.size
        average_face_height = heights.sum / heights.size
      
        # calculating the surrounding margin of the area that covers all the found faces
        #
      
        # new width
        @top_left_x -= average_face_width / 2
        @bottom_right_x += average_face_width / 2
      
        # new height
        @top_left_y -= average_face_height / 2
        @bottom_right_y += average_face_height / 1.6

        calculate_bounds
      
        # if the new area is smaller than the target geometry, it's scaled so the final image isn't resampled
        #
        if @faces_width < @target_geometry.width 
          delta_width = (@target_geometry.width - @faces_width) / 2
          @top_left_x -= delta_width
          @bottom_right_x += delta_width
          calculate_bounds
        end
      
        #raise (@target_geometry.height > 0 and @faces_height < @target_geometry.height).to_s
      
        if (@target_geometry.height > 0 and @faces_height < @target_geometry.height)
          delta_height = (@target_geometry.height - @faces_height) / 2
          @top_left_y -= delta_height
          @bottom_right_y += delta_height
          calculate_bounds
        end
      
        @faces_height = @faces_width if @target_geometry.height == 0
      
        @current_geometry = Paperclip::Geometry.new(@faces_width, @faces_height)
      end
    
    end
  
  
    def transformation_command
      return super unless @has_faces
    
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      faces_crop = "%dx%d+%d+%d" % [@faces_width, @faces_height, @top_left_x, @top_left_y]
    
      trans = []
      trans << "-crop" << %["#{faces_crop}"] << "+repage"
      trans << "-resize" << %["#{scale}"] unless scale.nil? || scale.empty?
      trans << "-crop" << %["#{crop}"] << "+repage" if crop
      trans
    end
  
    private
  
    # calculate_bounds
    #
    def calculate_bounds
      @top_left_x = 0 if @top_left_x < 0      
      @bottom_right_x = @current_geometry.width if @bottom_right_x > @current_geometry.width

      @top_left_y = 0 if @top_left_y < 0
      @bottom_right_y = @current_geometry.height if @bottom_right_y > @current_geometry.height
    
      @faces_width = @bottom_right_x - @top_left_x
      @faces_height = @bottom_right_y - @top_left_y
    end
  
    # detect_regions
    #
    def detect_regions(image, classifiers, color = OpenCV::CvColor::Blue)
      regions = []
    
      classifiers.each do |classifier|
        detector = OpenCV::CvHaarClassifierCascade::load(classifier)
        detector.detect_objects(image) do |region| 
          regions << region 
          image.rectangle!(region.top_left, region.bottom_right, :color => color) if self.debug 
        end
      end
    
      if self.debug 
        image.save_image(@file.path)
        Rails.logger.info(regions)
      end
    
      regions
    end
  end
end