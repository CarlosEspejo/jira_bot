require_relative 'jira_bot'
require 'httparty'
require 'pry'


bot = JiraBot.new(username: ENV['JIRA_BOT_USER'], password: ENV['JIRA_BOT_PASSWD'], base_url: ENV['JIRA_BOT_URL'], http: HTTParty)
r = bot.get "/search?jql=#{URI.encode('project=HELPSP and status=open')}"

r["issues"].each do |i| 
  puts i["fields"]["summary"]
  #puts i["fields"]["description"]
end
