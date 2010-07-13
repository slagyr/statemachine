require 'date'

module Statemachine
  module Generate
    module Util

      def create_file(filename, content)
        establish_directory(File.dirname(filename))
        File.open(filename, 'w') do |file|
          file.write(content)
        end
      end

      def establish_directory(path)
        return if File.exist?(path)
        establish_directory(File.dirname(path))
        Dir.mkdir(path)
      end

      def timestamp
        return DateTime.now.strftime("%H:%M:%S %B %d, %Y")
      end

      def endl
        return :endl
      end

    end
  end
end

class String
  def camalized(starting_case = :upper)
    value = self.downcase.gsub(/[_| |\-][a-z]/) { |match| match[-1..-1].upcase }
    value = value[0..0].upcase + value[1..-1] if starting_case == :upper
    return value
  end
end

class Symbol
  def <=>(other)
    return to_s <=> other.to_s
  end
end
