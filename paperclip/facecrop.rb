class Paperclip::FaceCrop < Paperclip::Thumbnail
  
  cattr_accessor :classifiers

  def initialize(file, options = {}, attachment = nil)
    super(file, options, attachment)
    
    
    x_coords = []
    y_coords = []
    widths   = []
    heights  = []
    
    image = OpenCV::IplImage.load(file.path)
    
    Paperclip::FaceCrop.classifiers.each do |classifier|
      detector = OpenCV::CvHaarClassifierCascade::load(classifier)
      detector.detect_objects(image) do |region|
        x_coords << region.top_left.x << region.bottom_right.x
        y_coords << region.top_left.y << region.bottom_right.y
        widths << region.width
        heights << region.height
      end
    end
    
    @has_faces = x_coords.size > 0
    
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
      
      if @faces_height < @target_geometry.height
        delta_height = (@target_geometry.height - @faces_height) / 2
        @top_left_y -= delta_height
        @bottom_right_y += delta_height
        calculate_bounds
      end
      
      @current_geometry = Paperclip::Geometry.new(@faces_width, @faces_height)
    end
    
  end

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
  
  
  def transformation_command
    return super unless @has_faces
    
    #raise "#{@current_geometry}-#{@target_geometry}"
    scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
    faces_crop = "%dx%d+%d+%d" % [@faces_width, @faces_height, @top_left_x, @top_left_y]
    
    #raise @current_geometry.to_s
    trans = []
    trans << "-crop" << %["#{faces_crop}"] << "+repage"
    trans << "-resize" << %["#{scale}"] unless scale.nil? || scale.empty?
    trans << "-crop" << %["#{crop}"] << "+repage" if crop
    trans
  end
end