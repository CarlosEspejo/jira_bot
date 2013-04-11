require_relative 'text_data'
require_relative 'bayes'
require 'json'

class JiraData < TextData
  attr_reader :assignees, :classifier, :word_excludes, :results, :training_cache

  def init(options)
    @classifier = options[:classifier]|| Bayes.new
  end

  def train(category, text)
    classifier.train category, text if text
  end

  def load_training
    @training_cache = JSON.parse(IO.read(File.expand_path('./training_cache.json', File.dirname(__FILE__))))
    @classifier.load_from_cache @training_cache if @training_cache
  end

  def cache_training
    File.write './training_cache.json', JSON.pretty_generate({data: classifier.list, training_count: classifier.training_count})
    puts 'cached training at ./training_cache.json'
  end

  def class_result(text)
    classifier.classify(text)
  end

  def classify(text)
    r = class_result(text)
    first, second = r.values.sort.reverse
    second ||= 0.5

    #puts "#{first} / #{second} = #{first / second}"
    @results = (first/second) > 1.5 ? r : :unknown
  end

  def max
    (results && results != :unknown) ? results.max_by{|k,v| v}: [results]
  end

  def train_on_users(cache = true)
    assignees.keys.each do |u|
      user_data = data.find_all{|d| d[:fields][:assignee][:name].downcase == u}
      user_data.each do |d|
        text = get_text d
        classifier.train u, text if text
      end
    end

    cache_training if cache
  end

  private

  def get_assignees
    list = Hash.new(0)
      data.each do |i|
      list[i[:fields][:assignee][:name].downcase] += 1
    end
    @assignees = list
  end

end
