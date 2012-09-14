require 'rest_client'

class FaceCrop::Detector::Lambda_Labs < FaceCrop::Detector::Base

  def detect_faces(file)

    require File.join(File.dirname(__FILE__), "FaceRecognition.rb")
    lambda_face = FaceRecognition.new(@options[:api_key], @options[:api_secret])

    response = lambda_face.detect(File.open(file))

    photo = response['photos'].first
    photo['tags'].map do |tag|
      # values are returned as percentual values
      x = (photo['width'] * (tag['center']['x'] / 100.0)).to_i
      y = (photo['height'] * (tag['center']['y'] / 100.0)).to_i
      w = (photo['width'] * (tag['width'] / 100)).to_i
      h = (photo['height'] * (tag['height'] / 100)).to_i

      region = FaceCrop::Detector::Region.new(x, y, w, h)
      region.color = "green"
      region
    end
  end
end
