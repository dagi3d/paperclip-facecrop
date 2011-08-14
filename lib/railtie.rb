module FaceCrop
  class Railtie < Rails::Railtie
    initializer "paperclip-facecrop.extend_has_attachment" do
      raise "Paperclip needed" unless defined?(Paperclip)
      ActiveSupport.on_load :active_record do
        
        class ActiveRecord::Base
          
          class << self
            def has_attached_file_with_face_crop_cache(name, args)
              has_attached_file_without_face_crop_cache(name, args)
              send("after_#{name}_post_process", lambda { FaceCrop::Detector::Cache.clear })
            end
            
            alias_method_chain :has_attached_file, :face_crop_cache
          end
        end
      end
      
    end
  end
end