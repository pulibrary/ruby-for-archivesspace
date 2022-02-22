require "httparty"
require 'mechanize'
require "open3"
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

    def execute!
      stdout, status = Open3.capture2("/usr/bin/env openconnect --protocol=gp --user=#{@username} --passwd-on-stdin vpn.princeton.edu", stdin_data: @secret)
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
        saml_cookies = agent.cookies.select { |cookie| cookie.domain == 'fed.princeton.edu' }
        if !saml_cookies.empty?
          if saml_cookies.length == 1
            @secret = saml_cookies.first.value
          else
            raise(NotImplementedError, "Multiple SAML digests stored as cookies: #{saml_cookies}")
          end
        elsif page.body.include?('duo_iframe')
          # Submit the multi-factor authentication form

          # Mechanize requires <iframe> interaction first
          agent.click(page.iframes.first)
          duo_page = page.iframes.first.content
          duo_form = duo_page.forms.first
          duo_form.username = @username
          duo_form.password = @password
          results_page = duo_form.submit
          @secret = agent.cookies.first.value

          binding.pry
        else
          raise(NotImplementedError, "Unhandled server response: #{page.uri}")
        end

        # Invoke the `openconnect binary with the SAML digest here
        execute!
      end
    end
  end
end

class Aspace < Thor
  desc "connect", "Connect to the Princeton University Library network"
  def connect
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
