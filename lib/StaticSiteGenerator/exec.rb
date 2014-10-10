
module StaticSiteGenerator

  module Exec

    class StaticSiteGenerator

      # Process any command line options, and run the StaticSiteGenerator
      def process_result
        engine = ::StaticSiteGenerator::Engine::Engine.new(Dir.getwd)
        engine.perform
      end
    end
  end
end