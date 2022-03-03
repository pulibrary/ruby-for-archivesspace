require "httparty"
require "irb"
require 'irb/completion'
require 'mechanize'
require "open3"
require 'pry-byebug'
require 'selenium-webdriver'
require "thor"
require 'webdrivers'

module Saml2
  class Idp
    attr_accessor :uri

    def initialize(protocol:, host:, path:)
      @uri = URI.parse("#{protocol}://#{host}#{path}")
    end
  end

  class Agent
    attr_reader :cookies

    def initialize(idp:, username:, password:, cli:)
      @idp = idp
      @username = username
      @password = password
      @cli = cli
    end

    def execute!
      @cli.say("Please invoke the following:")
      @cli.say("echo '#{@secret}' | /usr/bin/env openconnect --protocol=gp --user=#{@username} --passwd-on-stdin --verbose vpn.princeton.edu")
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

      chrome_args = ['headless']
      chrome_args = []
      logging_prefs = { browser: 'ALL' }
      options = Selenium::WebDriver::Chrome::Options.new(args: chrome_args, logging_prefs: logging_prefs)
      driver = Selenium::WebDriver.for(:chrome, options: options)
      driver.get(@idp.uri)

      auth_form = driver.find_element(tag_name: 'form', action: 'login')

      username_input = auth_form.find_element(name: 'username')
      username_input.send_keys(@username)

      password_input = auth_form.find_element(name: 'password')
      password_input.send_keys(@password)

      submit_button = auth_form.find_elements(tag_name: 'button', type: 'submit', value: 'Login').last
      submit_button.click

      @cli.say("Requesting authorization from Duo...")
      # Find the DUO button
      mfa_frames = driver.find_elements(tag_name: "iframe")

      driver.switch_to.frame(mfa_frames.first)

      mfa_buttons = driver.find_elements(class: "auth-button")
      while mfa_buttons.empty?
        sleep(0.1)
        mfa_buttons = driver.find_elements(class: "auth-button")
      end

      mfa_buttons.first.click
      sleep(0.5)

      @cli.say("Two-factor authorization request pushed from Duo...")
      while driver.current_url.include?('fed.princeton.edu')
        sleep(0.1)
      end

      driver.switch_to.default_content
      driver_cookies = driver.manage.all_cookies

      @cookies = HTTParty::CookieHash.new

      driver_cookies.each do |driver_cookie|
        c = "#{driver_cookie[:name]}=#{driver_cookie[:value]}; path=#{driver_cookie[:path]}; Httponly; Secure"
        @cookies.add_cookies(c)
      end

      driver.quit
      # End the session
    end
  end
end

class Aspace < Thor
  desc "console", "Connect to the Princeton University Library network"
  def console

    protocol = "https"
    host = "idp.princeton.edu"
    path = "/idp/profile/SAML2/Redirect/SSO"

    username = ask("Please enter your NetID:")
    password = ask("Please enter your password:", echo: false)
    say("Authenticating...")

    idp = Saml2::Idp.new(protocol: protocol, host: host, path: path)
    agent = Saml2::Agent.new(idp: idp, username: username, password: password, cli: self)
    agent.authenticate!

    binding.irb
    # From here, instruct users on how to user the client
  end
end
