require_relative '../lib/jira_data'
require_relative '../lib/bayes'
require_relative '../lib/word_count_stats'
require_relative '../lib/jira_bot'
require 'logger'
require 'fileutils'

require 'pry'


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

      current_assignee = i['fields']['assignee']['emailAddress'].split('@').first.downcase
      f.puts i['key']
      j.classify "#{i['fields']['summary']} #{i['fields']['description']}"

      puts "#{i['fields']['summary']} \n current #{current_assignee} new #{j.assignee}"
      logger.debug "Old: #{current_assignee} New: #{j.max} for #{i['fields']['summary']}"

      assignee = j.assignee

      unless assignee == :unknown || assignee == 'schacko' || assignee == current_assignee
        bot.assign_user i['self'], assignee
        message = "assigned #{assignee} to #{i['key']}"
        puts message
        logger.debug message
      end

      puts "\n\n"
    end
  end
end
