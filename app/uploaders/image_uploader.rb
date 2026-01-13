class ImageUploader < CarrierWave::Uploader::Base
  storage :aws if Rails.env.production?

  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :bg do
    process resize_to_fit: [1200, 800]
  end

  def extension_allowlist
    %w[jpg jpeg png]
  end
end
