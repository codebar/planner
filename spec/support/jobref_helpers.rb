module JobrefHelpers
  def script_tag_content(wrapper_class: '')
    page.find("script#{wrapper_class}", visible: false).native.text.strip
  end

  def job_json_ld(job)
    {
      '@context': 'http://schema.org',
      '@type': 'JobPosting',
      'title': job.title,
      'datePosted': job.published_on.to_time.iso8601,
      'description': job.description,
      'employmentType': 'FULL_TIME',
      'url': job_url(job),
      'jobLocation': {
        '@type': 'Place',
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': job.location,
          'streetAddress': job.company_address,
          'postalCode': job.company_postcode,
          'addressRegion': job.location
        },
      },
      'baseSalary': {
        '@type': 'MonetaryAmount',
        'currency': 'GBP',
        value: {
          '@type': 'QuantitativeValue',
          'value': job.salary,
          'unitText': 'YEAR'
        },
      },
      'hiringOrganization': {
        '@type': 'Organization',
        'name': job.company,
        'sameAs': job.company_website
      },
      'validThrough': job.expiry_date.end_of_day.to_time.iso8601,
    }
  end

  def remote_job_json_ld(job)
    {
      '@context': 'http://schema.org',
      '@type': 'JobPosting',
      'title': job.title,
      'datePosted': job.published_on.to_time.iso8601,
      'description': job.description,
      'employmentType': 'FULL_TIME',
      'url': job_url(job),
      'jobLocation': {
        '@type': 'Place',
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': job.location,
          'streetAddress': job.company_address,
          'postalCode': job.company_postcode,
          'addressRegion': job.location
        },
        'additionalProperty': {
          '@type': 'PropertyValue',
          'value': 'TELECOMMUTE'
        }
      },
      'baseSalary': {
        '@type': 'MonetaryAmount',
        'currency': 'GBP',
        value: {
          '@type': 'QuantitativeValue',
          'value': job.salary,
          'unitText': 'YEAR'
        },
      },
      'hiringOrganization': {
        '@type': 'Organisation',
        'name': job.company,
        'sameAs': job.company_website
      },
      'validThrough': job.expiry_date.end_of_day.to_time.iso8601,
    }
  end
end
