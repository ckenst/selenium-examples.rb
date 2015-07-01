# filename: spec_helper.rb

require 'selenium-webdriver'

RSpec.configure do |config|

	config.before(:each) do
		case ENV['host']
		when 'saucelabs'
			caps = Selenium::WebDriver::Remote::Capabilities.send(ENV['browser'])
      		caps.version = ENV['browser_version']
      		caps.platform = ENV['operating_system']
					caps["screenResolution"] = ENV['resolution']
      		caps[:name] = example.metadata[:full_description]

      		@driver = Selenium::WebDriver.for(
      			:remote,
      			url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub",
      			desired_capabilities: caps)
      	else
      		@driver = Selenium::WebDriver.for :firefox
					@driver.manage.window.resize_to(1280, 1024)
      	end
	end

	config.after(:each) do
            if ENV['host'] == 'saucelabs'
                  if example.exception.nil?
                        SauceWhisk::Jobs.pass_job @driver.session_id
                  else
                        SauceWhisk::Jobs.fail_job @driver.session_id
                  end
            end

		@driver.quit
	end
end
