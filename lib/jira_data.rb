require_relative 'text_data'
require 'json'
require 'pry'

class JiraData < TextData
  attr_accessor :data, :assignees

  def init
    @data = JSON.parse IO.read(File.expand_path(uri, File.dirname(__FILE__))), :symbolize_names => true
    get_assignees
  end

  def word_freq
    list = Hash.new(0)
    data.each do |d|

      text = ''
      text << d[:fields][:summary] if d[:fields][:summary]
      text << ' '
      text << d[:fields][:description] if d[:fields][:description]

      text.downcase.scan(/[a-z]+/).each do |w|
        list[w] += 1 unless stop_words.include? w
      end
    end

    list.sort_by{|word, count| count}.reverse
  end

  def split_on_topic(topic)

    topics = []
    data.each do |d|

      text = ''
      text << d[:fields][:summary] if d[:fields][:summary]
      text << ' '
      text << d[:fields][:description] if d[:fields][:description]

      if text =~ /#{topic}/
        topics << d
      end
    end
    topics 
  end

  
  def train(file)

  end

  private

  def get_assignees
    unless @assignees
      list = Hash.new(0)
      data.each do |i|
        list[i[:fields][:assignee][:name].downcase] += 1
      end
    end

    @assignees = list
  end

end
