Paperclip::FaceCrop
====================
`Paperclip::FaceCrop` is a [Paperclip][paperclip] processor that is aware of the faces found on the image 
so that they aren't cropped or aren't shown too small while generating the thumbnails.
It uses OpenCV for the facial recognition

![](https://github.com/dagi3d/paperclip-facecrop/raw/master/README_example.jpg)

Requirements:
-------------
- [OpenCV][opencv]
- [OpenCV ruby binding][ruby-opencv]

Installation:
-------------
- Add to `Gemfile`

          gem 'opencv'
- Copy `paperclip/facecrop.rb` into your `lib` directory
- Write an initializer setting the path of the haarcascade filters(`initializers/paperclip.rb` for example):   

          require 'paperclip/facecrop'
          Paperclip::FaceCrop.classifiers = ["/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt_tree.xml"]
    
You can use more than one filter if you want in order to try more accurate searches.

Usage:
------
Just specify your image styles as usual and set :face_crop as the processor:
    
    class Image < ActiveRecord::Base

      has_attached_file :attachment, 
          :styles => {:thumbnail => "200x125#"}, 
          :processors => [:face_crop]
    end
    
In case no faces were found, it will behave simply as the `Paperclip::Thumbnail` processor

Credits:
--------
Copyright (c) 2011 Borja Martín Sánchez de Vivar <borjamREMOVETHIS@dagi3d.net> - <http://dagi3d.net>, released under the MIT license  
The photo used as example belongs to [Jesper Rønn-Jensen](http://www.flickr.com/photos/jesper/)

[paperclip]: https://github.com/thoughtbot/paperclip
[opencv]: http://opencv.willowgarage.com/
[ruby-opencv]: https://github.com/ser1zw/ruby-opencv
