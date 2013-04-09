class WordCountStats

  attr_reader  :stop_words, :list, :training_count

  def initialize
    @stop_words = IO.read(File.expand_path('./stop_words.txt', File.dirname(__FILE__))).split
    @list = {}
    @training_count = Hash.new(0)
  end

  def train(category, text)
    list[category] ||= Hash.new(0)
    words = tokenize(text).each{|w, c| list[category][w] += c}

    scale = 1.0 / words.length
    list[category].keys.each {|key| list[key] *= scale if list[key]}

    training_count[category] += 1
    list
  end

  def classify text
    word_stems = tokenize text
    scores = {}

    list.each do |k, v|
      scores[k] = score(list[k], word_stems)
    end

    scores.sort_by{|k,v| v}.reverse
  end

  private
  def score (hash, word_list)
    score = 0.0
    word_list.each do |word, count|
      score += hash[word]
      binding.pry
    end

    (1000.0 * score) / word_list.size
  end

  def tokenize(text)
    words = Hash.new(0)
    text.downcase.scan(/[a-z]+/).each{|w| words[w] += 1.0 unless stop_words.include? w}
    words
  end


end
