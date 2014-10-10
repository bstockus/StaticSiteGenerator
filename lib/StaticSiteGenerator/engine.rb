require 'StaticSiteGenerator/site'

module StaticSiteGenerator

  module Engine

    class Engine

      def initialize(working_dir)
        @wd = working_dir
      end

      def perform()
        site = Site.new(@wd)
        site.render
      end

    end
  end
end