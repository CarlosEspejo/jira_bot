require_relative 'jira_bot'
require 'json'


bot = JiraBot.new username: ENV['JIRA_BOT_USER'], password: ENV['JIRA_BOT_PASSWD'], base_url: ENV['JIRA_BOT_URL']

index = 0
issues = []

while index < 500
  r = bot.get "/search?jql=project=HELPSP&startAt=#{index}&maxResults=500"
  r["issues"].each{|i| issues << i}
  index += 500
  puts index
end

File.write './issues.txt',issues.to_json
