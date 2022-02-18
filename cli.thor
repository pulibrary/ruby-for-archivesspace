require "httparty"
require 'mechanize'
require 'pry-byebug'
require "thor"

module Saml2
  class Idp
    attr_accessor :uri

    def initialize(protocol:, host:, path:)
      @uri = URI.parse("#{protocol}://#{host}#{path}")
    end
  end

  class Agent
    def initialize(idp:, username:, password:)
      @idp = idp
      @username = username
      @password = password
    end

    def authenticate!
      agent = Mechanize.new do |a|
        a.redirect_ok = true
      end

      @idp.uri = URI.parse("https://fed.princeton.edu/cas/login")
      params = {
        service: 'https://idp.princeton.edu/idp/Authn/External?conversation=e1s1',
        entityId: 'https://vpn.princeton.edu:443/SAML20/SP'
      }
      @idp.uri.query = URI.encode_www_form(params)

      # Retrieve the IdP authentication page
      agent.get(@idp.uri) do |page|

        # Submit the IdP authentication form
        auth_form = page.form_with(action: 'login')
        auth_form.username = @username
        auth_form.password = @password
        mfa_page = auth_form.submit

        # Submit the multi-factor authentication form
        mfa_form = mfa_page.form_with(action: '/cas/login')
        mfa_response = mfa_form.submit

        # Invoke the `openconnect binary with the SAML digest here
      end
    end
  end
end

class Aspace < Thor
  desc "auth", "Authenticate"
  def auth
    protocol = "https"
    host = "idp.princeton.edu"
    path = "/idp/profile/SAML2/Redirect/SSO"

    username = ask("Please enter your NetID:")
    password = ask("Please enter your password:", echo: false)

    idp = Saml2::Idp.new(protocol: protocol, host: host, path: path)
    agent = Saml2::Agent.new(idp: idp, username: username, password: password)
    agent.authenticate!
  end
end
