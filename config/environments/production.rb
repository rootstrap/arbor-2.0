Railsroot::Application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = false
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.version = '1.6'
  config.assets.digest = true
  config.log_level = :info
  config.assets.precompile += %w(
    vendor/modernizr.js
    stylesheets/application_pdf.css.scss
    stylesheets/application_reloaded_pdf.css.scss
    stylesheets/application_reload.scss
  )
  config.action_mailer.default_url_options = { host: ENV['DEFAULT_HOST'] }
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.react.variant = :production
  config.react.addons = true
end

ActionMailer::Base.smtp_settings = {
  address:              'smtp.sendgrid.net',
  port:                 '587',
  authentication:       :plain,
  user_name:            ENV['SENDGRID_USERNAME'],
  password:             ENV['SENDGRID_PASSWORD'],
  domain:               'heroku.com',
  enable_starttls_auto: true
}
