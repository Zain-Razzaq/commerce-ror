Rails.application.config.session_store :cookie_store, 
  key: 'session_token', 
  same_site: :none, 
  secure: false