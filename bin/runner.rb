require_relative '../lib/jira_data'
require_relative '../lib/bayes'
require 'pry'

j = JiraData.new('./issues.txt')
#j.train_on_users



binding.pry
