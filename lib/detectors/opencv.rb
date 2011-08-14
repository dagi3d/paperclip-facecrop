require 'opencv'
require File.expand_path('../opencv_ext', __FILE__)

class FaceCrop::Detector::OpenCV < FaceCrop::Detector::Base
  @color = "blue"
  
  def detect(file)
    image = OpenCV::IplImage.load(file, 1)

    faces_regions = detect_regions(image, @options[:classifiers][:face])
  
    #Paperclip::FaceCrop.classifiers[:nose]
    unless @options[:classifiers][:parts].nil?
      faces_parts_regions = detect_regions(image, @options[:classifiers][:parts])
    
      faces_regions.reject! do |face_region|
        region = faces_parts_regions.detect do |part_region|
          # part of a face can't be bigger than the face itself
          face_region.collide?(part_region) && face_region > part_region
        end
      
        region.nil?
      end
    end
    
    faces_regions
    
  end
  
  private
  def detect_regions(image, classifiers, color = OpenCV::CvColor::Blue)
    regions = []
  
    classifiers.each do |classifier|
      detector = OpenCV::CvHaarClassifierCascade::load(classifier)
      detector.detect_objects(image) do |region| 
        region.color = "red"
        regions << region 
      end
    end

    regions
  end
end
