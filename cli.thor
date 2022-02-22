require "httparty"
require 'mechanize'
require "open3"
require 'pry-byebug'
require "thor"
require 'selenium-webdriver'
require 'webdrivers'

module Saml2
  class Idp
    attr_accessor :uri

    def initialize(protocol:, host:, path:)
      @uri = URI.parse("#{protocol}://#{host}#{path}")
    end
  end

  class Agent
    def initialize(idp:, username:, password:, cli:)
      @idp = idp
      @username = username
      @password = password
      @cli = cli
    end

    def execute!
      #stdout, status = Open3.capture2("/usr/bin/env openconnect --protocol=gp --user=#{@username} --passwd-on-stdin --verbose vpn.princeton.edu", stdin_data: @secret)
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

      # chromedriver
      options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
      driver = Selenium::WebDriver.for(:chrome, options: options)

      driver.get(@idp.uri)

      #auth_form = page.form_with(action: 'login')
      #auth_form.username = @username
      #auth_form.password = @password

      auth_form = driver.find_element(tag_name: 'form', action: 'login')

      username_input = auth_form.find_element(name: 'username')
      username_input.send_keys(@username)

      password_input = auth_form.find_element(name: 'password')
      password_input.send_keys(@password)

      submit_button = auth_form.find_elements(tag_name: 'button', type: 'submit', value: 'Login').last
      submit_button.click

      # Find the DUO button
      mfa_frames = driver.find_elements(tag_name: "iframe")

      driver.switch_to.frame(mfa_frames.first)

      mfa_buttons = driver.find_elements(class: "auth-button")

      driver.save_screenshot("debug0.png")
      mfa_buttons.first.click
      sleep(0.5)
      driver.save_screenshot("debug1.png")

      cancel_button = driver.find_element(class: "btn-cancel")
      driver.save_screenshot("debug1b.png")

      @cli.say("Two-factor authorization request pushed to Duo...")
      while driver.current_url == 'localhost'
        sleep(0.2)
      end

      driver.switch_to.default_content

      content_div = driver.find_element(class: 'content')
      content_text = content_div.attribute("textContent").strip
      if content_text.include?("Sorry, it looks like there is a problem finding your session.")
        raise(StandardError, "Authorization Error: #{content_text}")
      end

      # End the session
      driver.quit
    end

    def mechanize!
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
        saml_cookies = agent.cookies.select { |cookie| cookie.domain == 'fed.princeton.edu' }

        # Submit the IdP authentication form if there is no authentication
        if saml_cookies.empty?
          auth_form = page.form_with(action: 'login')
          auth_form.username = @username
          auth_form.password = @password
          mfa_page = auth_form.submit
          saml_cookies = agent.cookies.select { |cookie| cookie.domain == 'fed.princeton.edu' }

          if mfa_page.body.include?('duo_iframe')
            # Submit the multi-factor authentication form

            # Mechanize requires <iframe> interaction first
            #agent.click(mfa_page.iframes.first)
            duo_page = mfa_page.iframes.first.content
            duo_form = duo_page.forms.first
            duo_form.username = @username
            duo_form.password = @password
            execution = duo_form.execution
            #duo_response = duo_form.submit
            #duo_response = agent.submit(duo_form, duo_form.buttons.first)

            uri = URI.parse("https://fed.princeton.edu/cas/login")
            params = {
              service: 'https://idp.princeton.edu/idp/Authn/External?conversation=e1s1',
              entityId: 'https://vpn.princeton.edu:443/SAML20/SP'
            }
            uri.query = URI.encode_www_form(params)
            duo_response = agent.post(uri, {
              username: @username,
              password: @password,
              execution: execution,
              _eventId: 'submit',
              geolocation: nil
            })

            # This is manual
            duo_uri = URI.parse("https://api-dc8397fa.duosecurity.com/frame/web/v1/auth")
            duo_params = {
              service: 'https://idp.princeton.edu/idp/Authn/External?conversation=e1s1',
              entityId: 'https://vpn.princeton.edu:443/SAML20/SP',
              tx: 'TX|anJnNXxESUpXRTA1NUdFNERHMUdVMU5IU3wxNjQ1NTUzNzI4|b845a02fe3c4697414246a31695b75477e188737',
              parent: duo_response.uri,
              v: '2.6'
            }
            duo_uri.query = URI.encode_www_form(duo_params)
            duo_response2 = agent.get(duo_uri)

            @secret = agent.cookies.first.value

            # https://idp.princeton.edu/idp/Authn/External?conversation=e1s1&ticket=ST-68462-L-1zl-dwUBs5FQKeDjtrIVAHVH4-fed
            # Wait for https://idp.princeton.edu/idp/profile/SAML2/POST/SSO?execution=e1s1&_eventId_proceed=1
            # Then POST SAMLResponse
            execute!
          else
            raise(NotImplementedError, "Unhandled server response: #{mfa_page.uri}")
          end
        else
          if saml_cookies.length == 1
            @secret = saml_cookies.first.value
          else
            raise(NotImplementedError, "Multiple SAML digests stored as cookies: #{saml_cookies}")
          end
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
    say("Authenticating...")

    idp = Saml2::Idp.new(protocol: protocol, host: host, path: path)
    agent = Saml2::Agent.new(idp: idp, username: username, password: password, cli: self)
    agent.authenticate!
  end
end
