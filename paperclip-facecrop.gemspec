# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = "paperclip-facecrop"
  s.version = "0.0.6"
  s.authors = ["Borja Martín"]
  s.description = %q{Paperclip processor that is aware of the faces detected on the image so that they don't get cropped or aren't shown too small while generating the thumbnails}
  s.summary = %q{Paperclip processor that is aware of the faces found on the image}
  s.email = "borjam@dagi3d.net"
  s.homepage = "http://github.com/dagi3d/paperclip-facecrop"
  s.require_paths = ["lib"]
  s.files = `git ls-files`.split("\n")
  s.has_rdoc = false
  s.add_runtime_dependency("paperclip")
  s.add_runtime_dependency("opencv", "= 0.0.6")
end