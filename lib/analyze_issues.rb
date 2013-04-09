require_relative 'jira_data'
require 'json'


class AnalyzeIssues
  attr_reader :data

  def initialize
    @data = JSON.parse IO.read(File.expand_path(uri, File.dirname(__FILE__))), :symbolize_names => true
  end

  def get_text(d)
    "#{d[:fields][:summary]} #{d[:fields][:description]}"
  end

  def text_at(n = 0)
    get_text data[n] if n < data.size
  end

  def tokenize(text)
    words = Hash.new(0)
    text.downcase.scan(/[a-z]+/).each{|w| words[w] += 1 unless stop_words.include? w}
    words
  end

end
