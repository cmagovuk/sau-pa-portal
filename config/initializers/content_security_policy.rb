# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self
    policy.img_src     :self,
                       "https://www.google-analytics.com",
                       "https://www.googletagmanager.com"
    policy.object_src  :none
    policy.script_src  :self,
                       "https://www.google-analytics.com",
                       "https://www.googletagmanager.com"
    policy.style_src   :self
    policy.base_uri    :none
    # If you are using webpack-dev-server then specify webpack-dev-server host
    policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?
  
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(_) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
