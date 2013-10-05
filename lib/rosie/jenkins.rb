require "json"
require "net/http"
require "uri"

module Rosie
  class JenkinsInvalidUrlError < Exception
  end

  class Jenkins
    # Jenkins server url
    attr_reader :url

    def initialize(url)
      raise JenkinsInvalidUrlError if has_bad_url?(url)
      @url = url
    end

    def has_bad_url?(url)
      uri = URI.parse(url)
      !uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      true
    end

    # Public: returns an Array of hashes of the type
    #
    # {:name => "", :url => ""}
    #
    # for all the build failures reported by
    # a Jenkins server
    def failures
      uri = URI.join(@url, "/api/", "json")
      response = Net::HTTP.get_response(uri)

      # Bail out fast if we don't get a HTTP 200 OK
      return nil, {:code => response.code, :message => response.message} unless
        response.code == "200"

      data = JSON.parse(response.body)
      failures = data.collect do |job|
        {:name => job["name"], :url => job["url"]} if
          job["color"].downcase.start_with? "red"
      end
      return failures.compact, nil

    end
  end
end
