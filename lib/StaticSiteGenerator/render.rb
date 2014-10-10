
require 'StaticSiteGenerator/site'
require 'StaticSiteGenerator/resource'
require 'StaticSiteGenerator/page'

module StaticSiteGenerator

  module Engine

    class RenderContext

      def initialize(base, parents, params)
        @base = base
        @parents = parents
        @params = params
        @required_styles = []
        @required_scripts = []
      end

      def get_base()
        return @base
      end

      def get_parents()
        return @parents
      end

      def get_params()
        return @params
      end

      def get_param(name)
        return @params[name]
      end

      def get_rel_path_to_page(name)
        return @base.get_page(name).get_page_rel_location
      end

      def require_style(name)
        if !@required_styles.include? name then
          @required_styles << name
          str = "        "
          @parents.each {|parent|
            str += "  "
          }
          str += "+Style:" + name
          puts str
        end
      end

      def require_script(name)
        if !@required_scripts.include? name then
          @required_scripts << name
          str = "        "
          @parents.each {|parent|
            str += "  "
          }
          str += "+Script:" + name
          puts str
        end
      end

      def get_required_styles()
        return @required_styles
      end

      def get_required_scripts()
        return @required_scripts
      end

      def render_partial(name, params = {})
        partial = @base.get_partial name
        partial_ctx = RenderContext.new(partial, @parents << self, params)
        results = partial_ctx.run
        @required_styles |= partial_ctx.get_required_styles
        @required_scripts |= partial_ctx.get_required_scripts
        return results
      end

      def trace()
        str = "      "
        @parents.each {|parent|
          str += "  "
        }
        str += @base.get_name + " " + @params.to_s
        puts str
      end

      def run()
        self.trace
        render_proc = self.get_base.get_engine.render_proc(self)
        return render_proc.call
      end

    end

    class LayoutRenderContext < RenderContext

      def initialize(base, parents, params, content = "", required_styles = [], required_scripts = [], trial_run = true)
        super(base, parents, params)
        @content = content
        @required_styles |= required_styles
        @required_scripts |= required_scripts
        @trial_run = trial_run
      end

      def render_content()
        return @content
      end

      def include_styles()
        if !@trial_run then
          str = ""
          @required_styles.each {|style_name|
            style = @base.get_style style_name
            str += "<link rel=\"stylesheet\" href=\"" + style.get_results_path + "\">\n"
          }
          return str
        else
          return ""
        end
      end

      def include_scripts()
        if !@trial_run then
          str = ""
          @required_scripts.each {|script_name|
            script = @base.get_script script_name
            str += "<script type=\"text/javascript\" src=\"" + script.get_results_path + "\"></script>\n"
          }
          return str
        else
          return ""
        end
      end
    end
  end
end