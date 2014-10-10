require 'sass'

require 'StaticSiteGenerator/site'

module StaticSiteGenerator

  module Engine

    class Resource

      def initialize(site, name, file, results_path)
        @site = site
        @name = name
        @file = file
        @results_path = results_path
      end

      def get_site()
        return @site
      end

      def get_results_path()
        return @results_path
      end
    end

    class Script < Resource
      def initialize(site, name, info)
        @type = 'js'
        if info.has_key? 'type' then
          @type = info['type']
        end
        super(site, name, info['file'], (File.join(site.scripts_rel_dir,name)) + '.js')
      end

      def get_type()
        return @type
      end

      def render()
        case @type
          when 'js'
            return @site.read_site_file(@file)
          else
            raise "ERROR: Unrecognized Script type: '" + @type + "'"
        end
      end
    end

    class Style < Resource
      def initialize(site, name, info)
        @type = 'css'
        if info.has_key? 'type' then
          @type = info['type']
        end
        super(site, name, info['file'], (File.join(site.styles_rel_dir,name)) + '.css')
      end

      def get_type()
        return @type
      end

      def render()
        case @type
          when 'css'
            return @site.read_site_file(@file)
          when 'sass'
            template = @site.read_site_file(@file)
            sass_engine = Sass::Engine.new(template)
            return sass_engine.render
          else
            raise "ERROR: Unrecognized Style type: '" + @type + "'"
        end
      end
    end
  end
end