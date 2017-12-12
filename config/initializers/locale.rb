# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
Rails.application.config.i18n.default_locale = :en
Rails.application.config.i18n.fallbacks = true
Rails.application.config.i18n.available_locales = [:en, :fr]
#config.i18n.enforce_available_locales = false
