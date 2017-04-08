module Tram
  class CommandLine
    BANNER = <<-EOS
Tram-policy is tool for context-related validation of objects, or mixes of objects.

Usage: tram-policy FILE_NAME MODEL_NAME ATTRIBUTES

Example: tram-policy user/readiness_policy user user:name user:email
    EOS

    # Creating a Tram::CommandLine runs from the contents of ARGV.
    def initialize
      system("rails g tram_policy #{ARGV.join(' ')}")
    end
  end
end
