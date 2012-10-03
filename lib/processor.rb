require File.expand_path('../face_crop', __FILE__)

module Paperclip
  class FaceCrop < Paperclip::Thumbnail

    @@debug = false

    #cattr_accessor :classifiers
    cattr_accessor :debug

    def self.detectors=(detectors)
      @@detectors = detectors.map do |name, options|
        #require File.expand_path("../detectors/#{name}", __FILE__)
        detector_class = "FaceCrop::Detector::#{name}".constantize
        detector = detector_class.new(options)
      end
    end

    def initialize(file, options = {}, attachment = nil)
      super(file, options, attachment)


      raise "No detectors were defined" if @@detectors.nil?

      faces_regions = []
      faces_parts_regions = []

      @@detectors.each do |detector|
        begin
          faces_regions += detector.detect(file.path)
        rescue Exception => e
          puts e
          Rails.logger.error(e)
        end
      end


      x_coords, y_coords, widths, heights = [], [], [], []

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



        #puts @top_left_x.to_s

        # average faces areas
        average_face_width  = widths.sum / widths.size
        average_face_height = heights.sum / heights.size

        # calculating the surrounding margin of the area that covers all the found faces
        #

        # new width
        @top_left_x -= average_face_width / 1.2
        @bottom_right_x += average_face_width / 1.2


        # new height
        #puts ":::#{@top_left_x}---#{average_face_width}"
        #return

        @top_left_y -= average_face_height / 1.2
        @bottom_right_y += average_face_height / 1.2


        calculate_bounds



        # if the new area is smaller than the target geometry, it's scaled so the final image isn't resampled
        #
        if @faces_width < @target_geometry.width
          delta_width = (@target_geometry.width - @faces_width) / 2
          @top_left_x -= delta_width
          @bottom_right_x += delta_width
          calculate_bounds
        end

        # scale the image so the cropped image still displays the faces
        if @faces_width > @target_geometry.width && crop?
          ratio = @faces_width / @target_geometry.width
          @faces_height = @target_geometry.height * ratio
        end

        #raise (@target_geometry.height > 0 and @faces_height < @target_geometry.height).to_s

        if (@target_geometry.height > 0 and @faces_height < @target_geometry.height)
          delta_height = (@target_geometry.height - @faces_height) / 2
          @top_left_y -= delta_height
          @bottom_right_y += delta_height
          calculate_bounds
        end


        #fix image position for extrem aspect ratios
        if @target_geometry.width / @target_geometry.height < 0.6
          @top_left_x = x_coords.min * 1.2
        end

        if @target_geometry.width / @target_geometry.height > 1.4
          @top_left_y = y_coords.min * 1.2
        end

        @faces_height = @faces_width if @target_geometry.height == 0

        @current_geometry = Paperclip::Geometry.new(@faces_width, @faces_height)

        if @@debug
          parameters = []
          parameters << "-stroke" << "green"
          parameters << "-fill" << "none"
          parameters << faces_regions.map {|r| "-stroke #{r.color} -draw 'rectangle #{r.top_left.x},#{r.top_left.y} #{r.bottom_right.x},#{r.bottom_right.y}'"}
          parameters << ":source"
          parameters << ":dest"
          parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

          Paperclip.run("convert", parameters, :source => "#{File.expand_path(file.path)}", :dest => "#{File.expand_path(file.path)}")
        end


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

  end
end