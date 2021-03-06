class GenericImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes, Piet::CarrierWaveExtension
  process optimize: [{ verbose: false, quality: 70 }]

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
