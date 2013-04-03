require 'pry'

class Bayes
  attr_reader  :stop_words, :categories, :training_count

  def initialize
    @stop_words = IO.read(File.expand_path('./stop_words.txt', File.dirname(__FILE__))).split
    @categories = {}
    @training_count = Hash.new(0)
  end

  def tokenize(text)
    words = Hash.new(0)
    text.downcase.scan(/[a-z]+/).each{|w| words[w] += 1 unless stop_words.include? w}
    words
  end

  def train(category, text)
    categories[category] ||= Hash.new(0)
    tokenize(text).each{|w, c| categories[category][w] += c}
    training_count[category] += 1
    categories
  end

  def sample_train
    train 'good', 'Nobody owns the water.'
    train 'good', 'the quick rabbit jumps fences'
    train 'bad', 'buy pharmaceuticals now'
    train 'bad', 'make quick money at the online casino'
    train 'good', 'the quick brown fox jumps'
  end

  def word_in_category_prob(category, word)
    word_count(category, word) / document_count(category)
  end

  def word_count(category, word)
    return 0.0 unless categories.has_key? category
    categories[category][word].to_f
  end

  def document_count(category)
    training_count[category] == 0 ? 0.0 : training_count[category].to_f
  end

  def total_document_count
    training_count.values.inject{|sum, v| sum + v}.to_f
  end

  def document_prob(category, text)
    words = tokenize text
    total = 1.0
    words.each{|w, c| total *= word_in_category_prob(category, w)}
    total
  end

  def prob(category, text)
    category_prob = document_count(category)/total_document_count
    doc_prob = document_prob category, text

    doc_prob * category_prob
  end

  def weighted_word_in_category_prob(category, word, weight=1.0, ap=0.5)
    basic_prob = word_in_category_prob(category, word)
    totals = categories.map{|cat, c| categories[cat][word]}.inject{|sum, v| sum + v}
    ((weight * ap) + (totals * basic_prob)) / (weight + totals)
  end

end
