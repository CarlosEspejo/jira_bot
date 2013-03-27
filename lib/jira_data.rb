require_relative 'text_data'
require 'json'
require 'pry'

class JiraData < TextData
  attr_accessor :assignee_list

  def train(file)
    issues = JSON.parse IO.read(File.expand_path(file, File.dirname(__FILE__))), :symbolize_names => true

    list = Hash.new(0)
    issues.each do |i|
      list[i[:fields][:assignee][:name].downcase] += 1
    end

    @assignee_list= list

    common = Hash.new(0)
    issues_count = 0
    issues.find_all{|f| ['carlos', 'cespejo'].include? f[:fields][:assignee][:name].downcase}.each do |i|

      text = ''
      text << i[:fields][:summary]
      text << " " + i[:fields][:description] unless i[:fields][:description].nil?

      words = text.downcase.scan(/[a-z]+/)

      clean_words = words - stop_words

      clean_words.each do |w|
        common[w] += 1
      end

      issues_count += 1
    end

    File.open('results.txt', 'w') do |f|
      f.puts "Carlos \t #{issues_count} tickets \t #{common.size} common words\n\n"
      f.puts "Common Words\n"

      common.sort_by{|k,v|  v}.reverse.each do |k, y|
        f.puts "#{k}            #{y}"
      end
    end
  end
end
