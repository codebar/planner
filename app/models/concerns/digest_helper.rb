module DigestHelper
  def md5_of(identifier)
    return '' if identifier.nil?

    Digest::MD5.hexdigest(identifier.to_s.strip.downcase)
  end
end
