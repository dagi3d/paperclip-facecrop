require File.join(File.dirname(__FILE__), "/mashape/mashape")

class FaceRecognition
	PUBLIC_DNS = "lambda-face-recognition.p.mashape.com"

	def initialize(public_key, private_key)
		@authentication_handlers = Array.new
		@authentication_handlers << Mashape::MashapeAuthentication.new(public_key, private_key)
	end


	def createAlbum(album,&callback)
		parameters = {
			"album" => album
		}
		return Mashape::HttpClient.do_request(:post, "https://" + PUBLIC_DNS + "/album", parameters, :form, :json, @authentication_handlers, &callback)
	end

	def detect(files=nil,urls=nil,&callback)
		parameters = {
			"files" => files,"urls" => urls
		}
		return Mashape::HttpClient.do_request(:post, "https://" + PUBLIC_DNS + "/detect", parameters, :binary, :json, @authentication_handlers, &callback)
	end

	def rebuildAlbum(album,albumkey,&callback)
		parameters = {
			"album" => album,"albumkey" => albumkey
		}
		return Mashape::HttpClient.do_request(:get, "https://" + PUBLIC_DNS + "/album_rebuild", parameters, :form, :json, @authentication_handlers, &callback)
	end

	def recognize(album,albumkey,files=nil,urls=nil,&callback)
		parameters = {
			"album" => album,"albumkey" => albumkey,"files" => files,"urls" => urls
		}
		return Mashape::HttpClient.do_request(:post, "https://" + PUBLIC_DNS + "/recognize", parameters, :binary, :json, @authentication_handlers, &callback)
	end

	def trainAlbum(album,albumkey,entryid,files=nil,rebuild=nil,urls=nil,&callback)
		parameters = {
			"album" => album,"albumkey" => albumkey,"entryid" => entryid,"files" => files,"rebuild" => rebuild,"urls" => urls
		}
		return Mashape::HttpClient.do_request(:post, "https://" + PUBLIC_DNS + "/album_train", parameters, :binary, :json, @authentication_handlers, &callback)
	end

	def viewAlbum(album,albumkey,&callback)
		parameters = {
			"album" => album,"albumkey" => albumkey
		}
		return Mashape::HttpClient.do_request(:get, "https://" + PUBLIC_DNS + "/album", parameters, :form, :json, @authentication_handlers, &callback)
	end

	def viewEntry(album,albumkey,entryid,&callback)
		parameters = {
			"album" => album,"albumkey" => albumkey,"entryid" => entryid
		}
		return Mashape::HttpClient.do_request(:get, "https://" + PUBLIC_DNS + "/album_train", parameters, :form, :json, @authentication_handlers, &callback)
	end
	
end
