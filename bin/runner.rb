require '../lib/jira_data'
require 'pry'

j = JiraData.new
j.train '../issues.txt'

