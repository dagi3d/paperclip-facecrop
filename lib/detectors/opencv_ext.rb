class OpenCV::CvAvgComp
  
  attr_accessor :color
  
  # collide?
  #
  def collide?(comp)
    if (self.x < comp.x + comp.width && comp.x < self.x + self.width && self.y < comp.y + comp.height)
      return comp.y < self.y + self.height
    end
    return false
  end
  
  def >(comp)
    self.area > comp.area
  end
  
  def <(comp)
    self.area < comp.area
  end
  
  
  def area
    return self.width * self.height
  end
  
  def to_s
    "#{self.x},#{self.y}-#{self.width}x#{self.height}"
  end
end