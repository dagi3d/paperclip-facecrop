

class FaceCrop::Detector::LambdaLabs < FaceCrop::Detector::Base

  def detect_faces(file)
    require File.expand_path('../lambda_libs/FaceRecognition', __FILE__)
    lambda_face = FaceRecognition.new(@options[:api_key], @options[:api_secret])
    response = lambda_face.detect(File.open(file)).body

    puts response

    photo = response['photos'].first
    photo['tags'].map do |tag|
      # values are returned as percentual values

      x = tag['center']['x'].to_i
      y = tag['center']['y'].to_i
      w = tag['width'].to_i
      h = tag['height'].to_i

      region = FaceCrop::Detector::Region.new(x, y, w, h)
      region.color = "blue"
      region
    end
  end
end
