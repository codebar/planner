# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  storage :aws if Rails.env.production?

  include CarrierWave::MiniMagick

  def content_type_allowlist
    [/image\//]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [178, 65]
  end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end
end
