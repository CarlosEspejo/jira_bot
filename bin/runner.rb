require_relative '../lib/jira_data'
require_relative '../lib/bayes'
require_relative '../lib/word_count_stats'
require_relative '../lib/jira_bot'
require 'logger'
require 'fileutils'

require 'pry'

#FileUtils.remove './classify.log', :force => true
#FileUtils.remove './issue_history.txt', :force => true

j = JiraData.new(uri: './issues.txt', classifier: Bayes.new)
j.load_training

bot = JiraBot.new username: ENV['JIRA_BOT_USER'], password: ENV['JIRA_BOT_PASSWD'], base_url: ENV['JIRA_BOT_URL']
response = bot.get_issues

issue_history = IO.read('./issue_history.txt').split if File.exists? './issue_history.txt'
issue_history ||= []

logger = Logger.new('./classify.log')

File.open './issue_history.txt', 'a' do |f|
  response['issues'].each do |i|
    unless issue_history.include? i['key']
      f.puts i['key']
      puts i['fields']['summary']

      j.classify "#{i['fields']['summary']} #{i['fields']['description']}"

      puts j.max
      logger.debug "#{j.max} for #{i['fields']['summary']}"

      puts "\n\n"
    end
  end
end
