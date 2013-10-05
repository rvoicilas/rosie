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
        def build_job(job_name, color)
          {"name" => job_name, "url" => "#{url}/job/#{job_name}", "color" => color}
        end

        jobs = [
                ["rosie.rb-dev", "red"],
                ["rosie.rb-staging", "blue_anime"],
                ["rosie.rb-prod", "blue"]
               ].collect { |job, color| build_job(job, color) }

        stub_request(:get, failures_url).
          to_return(:status => 200, :body => jobs.to_json)

        failures, error = jenkins.failures
        error.should be_nil
        failures.length.should == 1
        expected = {:name => "rosie.rb-dev", :url => "#{url}/job/rosie.rb-dev"}
        failures[0].should == expected
      end

      it "return an error when they can't be retrieved" do
        stub_request(:get, failures_url).
          to_return(:status => [404, "Not Found"])
        failures, error = jenkins.failures
        error.should == {:code => "404", :message => "Not Found"}
        failures.should be_nil
      end
    end
  end
end
