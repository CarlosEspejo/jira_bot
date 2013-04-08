require_relative 'text_data'
require_relative 'bayes'
require 'json'
require 'benchmark'

class JiraData < TextData
  attr_reader :data, :assignees, :bay, :word_excludes, :results, :training_cache

  def init
    time('booting up') do
      @data = JSON.parse IO.read(File.expand_path(uri, File.dirname(__FILE__))), :symbolize_names => true
      @bay = Bayes.new
      @word_excludes = IO.read(File.expand_path('./word_excludes.txt', File.dirname(__FILE__))).split
      get_assignees
    end
  end

  def time(title, &block)
    puts "#{title}..."
    time = Benchmark.realtime do
      block.call if block_given?
    end
    puts "Finished in #{time} seconds\n\n"
  end

  def train_on_users(cache = true)
    time 'training on users' do
      assignees.keys.each do |u|
        user_data = data.find_all{|d| d[:fields][:assignee][:name].downcase == u}
        user_data.each do |d|
          text = get_text d
          bay.train u, text if text
        end
      end

      cache_training if cache
    end
  end

  def load_training
    @training_cache = JSON.parse(IO.read('./training_cache.json')) #if File.exists?(File.expand_path('./training_cache.json', File.dirname(__FILE__)))
    @bay.load_from_cache @training_cache if @training_cache
    binding.pry
  end

  def cache_training
    File.write './training_cache.json', JSON.pretty_generate(bay.categories)
  end

  def train(category, text)
    time('Training') do
      bay.train category, text if text
    end
  end

  def bay_result(text)
    bay.classify(text)
  end

  def classify(text)
    r = bay_result(text)

    first, second = r.values.sort.reverse
    second ||= 1.0
    
    puts "#{first} / #{second} = #{first / second}"
    @results = (first/second) > 0.5 ? r : :unknown
  end

  def get_text(d)
    "#{d[:fields][:summary]} #{d[:fields][:description]}"
  end

  def text_at(n = 0)
    get_text data[n] if n < data.size
  end

  def max
    results.max_by{|k,v| v} if results && results != :unknown
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
