require 'httparty'
require 'json'

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

  def put(uri, data)
    options = {body: data.to_json}
    options = options.merge auth
    options[:headers] =  {'Content-Type' => 'application/json'}

    @response = party.put(uri, options)
  end

  def get_issues
    get URI.encode '/search?jql=project=HELPSP and status=open'
  end

  def assign_user(issue_uri, username)
    put issue_uri, {fields: {assignee: {name: username}}}
  end

  private
  def expand(uri)
    "#{base_url}#{uri}"
  end
end
