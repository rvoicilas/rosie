require "spec_helper"
require "webmock/rspec"
require_relative "../lib/rosie/jenkins"

module Rosie
  describe Jenkins do
    it "has a url" do
      Jenkins.new("http://www.google.com").should respond_to :url
    end

    it "complains if there's a bad url" do
      expect { Jenkins.new("wrong url") }.to raise_error(JenkinsInvalidUrlError)
    end

    context "build failures" do
      let (:url) { "http://jekins.builds.org" }
      let (:failures_url) { "#{url}/api/json" }
      let (:jenkins) { Jenkins.new(url) }
      
      it "can be listed" do
        jobs = [
                {"name" => "rosie.rb-dev", "url" => "#{url}/job/rosie-dev", "color" => "red"},
                {"name" => "rosie.rb-staging", "url" => "#{url}/job/rosie-staging", "color" => "blue_anime"},
                {"name" => "rosie.rb-prod", "url" => "#{url}/job/rosie-prod", "color" => "blue"}
               ]

        stub_request(:get, failures_url).
          to_return(:status => 200, :body => jobs.to_json)

        failures, error = jenkins.failures
        error.should be_nil
        failures.length.should == 1
        expected = {:name => "rosie.rb-dev", :url => "#{url}/job/rosie-dev"}
        failures[0].should == expected
      end

      it "returns an error when it can't get build failures" do
        stub_request(:get, failures_url).
          to_return(:status => [404, "Not Found"])
        failures, error = jenkins.failures
        error.should == {:code => "404", :message => "Not Found"}
        failures.should be_nil
      end
    end
  end
end
