module FaceCrop
  class Railtie < Rails::Railtie
    initializer "paperclip-facecrop.extend_has_attachment" do
      raise "Paperclip needed" unless defined?(Paperclip)
      puts Paperclip::VERSION
      #class ActiveRecord::Base
      #  alias_method_chain :has_attached_file, :cache
      #end
    end
  end
end