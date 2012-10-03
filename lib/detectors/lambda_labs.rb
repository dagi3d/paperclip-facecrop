require 'rest_client'

class FaceCrop::Detector::LambdaLabs < FaceCrop::Detector::Base
  URL = "https://lambda-face-recognition.p.mashape.com/detect"

  def detect_faces(file)
    response = RestClient.post(URL,
                               {:files => File.new(file)},
                               {:content_type => 'json', "X-Mashape-Authorization" => @options[:mashape_authorization]})

    response = JSON.parse(response)

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