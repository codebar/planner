Premailer::Rails.config.merge!(
  preserve_styles: true,
  strategies: [:filesystem, :asset_pipeline]
)
