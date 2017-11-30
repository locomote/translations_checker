module TranslationsChecker
  module TerminalColours
    COLOURS = {
      black:   "\e[30m",
      red:     "\e[31m",
      green:   "\e[32m",
      yellow:  "\e[33m",
      blue:    "\e[34m",
      magenta: "\e[35m",
      cyan:    "\e[36m",
      white:   "\e[37m"
    }.freeze
    ATTRIBUTES_OFF = "\e[0m".freeze

    COLOURS.each_key do |colour|
      define_method(colour) { |string| colourize(string, colour) }
    end

    module_function

    def colourize(string, colour)
      return nil unless string

      colour = COLOURS[colour.to_sym] || ATTRIBUTES_OFF
      "#{colour}#{string}#{ATTRIBUTES_OFF}"
    end
  end
end
