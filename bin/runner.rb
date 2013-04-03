require_relative '../lib/jira_data'
require_relative '../lib/basic_bayes'
require 'pry'

j = JiraData.new('../issues.txt')
d = j.split_on_topic('aicpa').join ' '

b = BasicBayes.new

b.train [
          {category: 'aicpa', data: d}
        ]

r = b.classify_plain_text "i need urgent xml file dump"


binding.pry
