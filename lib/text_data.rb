
class TextData
  attr_reader :uri, :stop_words
  def initialize(options)
    @uri = options[:uri]
    init(options)
  end

  def init(options = {})
    raise NotImplementedError
  end
end
