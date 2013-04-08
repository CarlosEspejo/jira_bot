require_relative '../lib/jira_data'
require_relative '../lib/bayes'
require_relative '../lib/jira_bot'
require 'pry'

j = JiraData.new('./issues.txt')
j.load_training

bot = JiraBot.new username: ENV['JIRA_BOT_USER'], password: ENV['JIRA_BOT_PASSWD'], base_url: ENV['JIRA_BOT_URL']
#issues = bot.get_issues

binding.pry
