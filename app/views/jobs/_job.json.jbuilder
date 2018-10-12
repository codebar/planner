json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'

json.title job.title
json.datePosted job.published_on.to_time.iso8601
json.description job.description

json.employmentType 'FULL_TIME'
json.url job_url(job)

json.jobLocation do
  json.set! '@type', 'Place'
  json.address do
    json.set! '@type', 'PostalAddress'
    json.addressLocality job.location
    json.streetAddress job.company_address
    json.postalCode job.company_postcode
    json.addressRegion job.location
  end

  if job.remote?
    json.additionalProperty do
      json.set! '@type', 'PropertyValue'
      json.value 'TELECOMMUTE'
    end
  end
end

json.baseSalary do
  json.set! '@type', 'MonetaryAmount'
  json.currency 'GBP'
  json.value do
    json.set! '@type', 'QuantitativeValue'
    json.value job.salary
    json.unitText 'YEAR'
  end
end

json.hiringOrganization do
  json.set! '@type', 'Organization'
  json.name job.company
  json.sameAs job.company_website
end

json.validThrough job.expiry_date.end_of_day.to_time.iso8601
