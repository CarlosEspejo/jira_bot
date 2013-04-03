
class TextData
  attr_reader :uri, :stop_words
  def initialize(uri = '')
    @uri = uri
    @stop_words = IO.read(File.expand_path('./stop_words.txt', File.dirname(__FILE__))).split
    init
  end

  def init
    raise NotImplementedError
  end
end
