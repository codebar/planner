xml.instruct!

# `maximum(:updated_at).to_f` — a raw Time in a cache key is stringified with
# second precision, so changes made within the same second would be missed.
# expires_in makes sections stale after record deletions self-heal.
xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
  cache 'sitemap/static', expires_in: 1.week do
    sitemap_static_urls.each { |url| xml.url { xml.loc(url) } }
  end

  sitemap_record_sections.each do |section|
    cache ['sitemap', section[:name], section[:records].maximum(:updated_at).to_f], expires_in: 1.day do
      section[:records].find_each do |record|
        xml.url do
          xml.loc(section[:url].call(record))
          xml.lastmod(record.updated_at.utc.iso8601)
        end
      end
    end
  end
end
