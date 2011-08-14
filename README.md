Paperclip::FaceCrop
====================
`Paperclip::FaceCrop` is a [Paperclip][paperclip] processor that is aware of the faces found on the image 
so that they aren't cropped or aren't shown too small while generating the thumbnails.
It can use the [OpenCV][opencv] library or the [Face.com][face_com] web service(or both at the same time) for the facial recognition.

![](https://github.com/dagi3d/paperclip-facecrop/raw/master/README_example.jpg)

Requirements:
-------------

### OpenCV

If you want to use OpenCV on your own server, you need to install:

- [OpenCV][opencv]
- [OpenCV ruby binding][ruby-opencv]

In case you get the error message `/ext/opencv/cverror.cpp:143: error: ‘CV_GpuCufftCallError’ was not declared in this scope` while installing the ruby binding,
checkout the OpenCV_2.2 branch or just remove the line 143 from `/ext/opencv/cverror.cpp`
          

### Face.com
- [rest-client][rest-client]

In order to use the Face.com service, you will also need to register in order to get your aapi key and api secret for your application.


Installation:
-------------
- Add to your application `Gemfile`

          gem 'paperclip-facecrop'
          
- Type
          
          bundle install


- Write an initializer setting the detectors configuration (`initializers/paperclip.rb` for example):   

### OpenCV

Set the path of the haarcascade filters:

          Paperclip::FaceCrop.detectors = {
            'OpenCV' =>  { 
              :face => %w(/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt_tree.xml)
            }
          }

          
              
You can use more than one filter to try more accurate searches:
    
          Paperclip::FaceCrop.detectors = {
            'OpenCV' =>  { 
              :face => %w(/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt_tree.xml
                          /usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt.xml
                          /usr/local/share/opencv/haarcascades/haarcascade_profileface.xml)
            }
          }



In order to try to avoid some false positives, you can also specify other classifiers to detect other parts of the face. In that case, 
only the found areas that contain parts like a mouth, an eye or a nose will be considered a face:
    
          Paperclip::FaceCrop.detectors = {
            'OpenCV' =>  { 
              :face => %w(/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt_tree.xml
                          /usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt.xml
                          /usr/local/share/opencv/haarcascades/haarcascade_profileface.xml),
              
              :parts => %w(/usr/local/share/opencv/haarcascades/haarcascade_mcs_nose.xml
                           /usr/local/share/opencv/haarcascades/haarcascade_mcs_lefteye.xml
                           /usr/local/share/opencv/haarcascades/haarcascade_mcs_righteye.xml)
            }
          }
          
    
### Face.com

          Paperclip::FaceCrop.detectors = {
            'FaceCom' => { :api_key => "<YOUR API KEY>", :api_secret => "<YOUR API SECRET>"}
          }    


Usage:
------
Just specify your image styles as usual and set :face_crop as the processor:
    
    class Image < ActiveRecord::Base

      has_attached_file :attachment, 
          :styles => {:thumbnail => "200x125#"}, 
          :processors => [:face_crop]
    end
    
In case no faces were found, it will behave simply as the `Paperclip::Thumbnail` processor


You can also set the debug mode to draw on the image the detected regions:
    
    Paperclip::FaceCrop.debug = Rails.env.development?
    
![](https://github.com/dagi3d/paperclip-facecrop/raw/master/README_example_b.jpg)

Each detector will draw the found regions in different colors(Face.com detector in red and OpenCV in green)

Credits:
--------
Copyright (c) 2011 Borja Martín Sánchez de Vivar <borjamREMOVETHIS@dagi3d.net> - <http://dagi3d.net>, released under the MIT license  
The photo used as example belongs to [Jesper Rønn-Jensen](http://www.flickr.com/photos/jesper/)

[face_com]: http://face.com
[rest-client]: https://rubygems.org/gems/rest-client
[paperclip]: https://github.com/thoughtbot/paperclip
[opencv]: http://opencv.willowgarage.com/
[ruby-opencv]: https://github.com/ser1zw/ruby-opencv
