class Log
  def self.info(text)
    puts text
  end

  def self.debug(text)
    puts "\e[#{34}m#{text}\e[0m"
  end
end