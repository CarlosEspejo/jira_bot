require_relative 'text_data'
require_relative 'bayes'
require 'json'
require 'benchmark'
require 'pry'

class JiraData < TextData
  attr_accessor :data, :assignees, :bay, :word_excludes

  def init
    with_timing do
      @data = JSON.parse IO.read(File.expand_path(uri, File.dirname(__FILE__))), :symbolize_names => true
      @bay = Bayes.new
      @word_excludes = IO.read(File.expand_path('./word_excludes.txt', File.dirname(__FILE__))).split
      get_assignees
    end
  end

  def with_timing(&block)
    puts "Started..."
    time = Benchmark.realtime do
      yield
    end
    puts "Finished in #{time} seconds"
  end

  def train_on_users
    puts "Training..."

    time = Benchmark.realtime do
      assignees.keys.each do |u|
        user_data = data.find_all{|d| d[:fields][:assignee][:name].downcase == u}
        user_data.each do |d|
          text = get_text d
          bay.train u, text if text
        end
      end
    end

    puts "Trained in #{time} seconds"
  end

  def train(category, text)
    with_timing do
      bay.train category, text if text
    end
  end

  def classify(text)
    r = bay.classify(text)
    r == :unknown ? r : r.sort_by{|k,v| v}.reverse
  end

  def get_text(d)
    text = ''
    text << d[:fields][:summary] if d[:fields][:summary]
    text << ' '
    text << d[:fields][:description] if d[:fields][:description]
  end

  def text_at(n = 0)
    get_text data[n] if n < data.size
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
