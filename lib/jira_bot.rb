require 'httparty'

class JiraBot
  attr_reader :username, :password, :base_url, :auth, :response, :party

  def initialize(options={})
    @username = options[:username]
    @password = options[:password]
    @base_url = options[:base_url]
    @auth = {:basic_auth => {username: username, password: password}}
    @party = options[:http] || HTTParty
  end

  def get(uri)
    uri = expand uri
    @response = party.get(uri, auth)
  end

  private
  def expand(uri)
    "#{base_url}#{uri}"
  end
end
