require 'haml'

require 'StaticSiteGenerator/render'
require 'StaticSiteGenerator/site'

module StaticSiteGenerator

  module Engine

    class BasePage

      def initialize(site, name, info)
        @site = site
        @name = name
        @file = info['file']
        @text = @site.read_site_file(@file)
        @engine = nil
      end

      def get_engine()
        if @engine.nil? then
          @engine = Haml::Engine.new(@text)
        end
        return @engine
      end

      def get_name()
        return @name
      end

      def get_partial(name)
        return @site.get_partial name
      end

      def get_style(name)
        return @site.get_style name
      end

      def get_script(name)
        return @site.get_script name
      end

      def get_page(name)
        return @site.get_page name
      end

    end

    class Page < BasePage

      def initialize(site, name, info)
        super(site, name, info)
        if info.has_key? 'layout' then
          if info['layout'].has_key? 'name' then
            @layout_name = info['layout']['name']
          else
            @layout_name = site.get_default_layout_name
          end
          if info['layout'].has_key? 'params' then
            @layout_params = info['layout']['params']
          else
            @layout_params = {}
          end
        else
          @layout_name = site.get_default_layout_name
          @layout_params = {}
        end

      end

      def get_layout()
        return @site.get_layout(@layout_name)
      end

      def get_layout_params()
        return @layout_params
      end

      def get_page_rel_location()
        return '/' + self.get_name + '.html'
      end

      def render_page()
        puts "    Content>"
        content_ctx = RenderContext.new(self, [], {})
        content = content_ctx.run
        layout = self.get_layout
        puts "    Layout(Trial)>"
        layout_ctx = LayoutRenderContext.new(layout, [], self.get_layout_params)
        layout_ctx.run
        required_styles = content_ctx.get_required_styles | layout_ctx.get_required_styles
        required_scripts = content_ctx.get_required_scripts | layout_ctx.get_required_scripts
        puts "    Layout>"
        layout_ctx = LayoutRenderContext.new(self.get_layout, [], self.get_layout_params, content, required_styles, required_scripts, false)
        return layout_ctx.run
      end

    end
  end
end