require 'fileutils'
require 'yaml'

require 'StaticSiteGenerator/resource'
require 'StaticSiteGenerator/page'

module StaticSiteGenerator

  module Engine

    class Site

      def initialize(site_dir, options = {})
        @site_dir = site_dir
        @options = options
        @layouts = {}
        @partials = {}
        @scripts = {}
        @styles = {}
        @pages = {}
        @scripts_rel_dir = "/scripts/"
        @styles_rel_dir = "/styles/"
        @default_layout_name = nil
      end

      def get_layout(name)
        return @layouts[name]
      end

      def get_partial(name)
        return @partials[name]
      end

      def get_script(name)
        return @scripts[name]
      end

      def get_style(name)
        return @styles[name]
      end

      def get_page(name)
        return @pages[name]
      end

      def get_default_layout_name()
        return @default_layout_name
      end

      def read_site_file(name)
        return self.read_file(@site_dir, name)
      end

      def read_file(dir, name)
        file = File.open(File.join(dir, name), "rb")
        text = file.read
        file.close
        return text
      end

      def write_file(dir, name, text)
        File.write(File.join(dir, name), text)
      end

      def make_and_clear_directory(name)
        path = name
        if Dir.exists? path then
          FileUtils.rm_rf(Dir.glob(File.join(path, "*")))
        else
          Dir.mkdir(path)
        end
      end

      def results_dir()
        return File.join(@site_dir, 'results')
      end

      def scripts_results_dir()
        return File.join(self.results_dir, 'scripts')
      end

      def styles_results_dir()
        return File.join(self.results_dir, 'styles')
      end

      def scripts_rel_dir()
        return @scripts_rel_dir
      end

      def styles_rel_dir()
        return @styles_rel_dir
      end

      def make_and_clean_results_dir()
        self.make_and_clear_directory self.results_dir
        self.make_and_clear_directory self.scripts_results_dir
        self.make_and_clear_directory self.styles_results_dir
      end

      def load_config(config_info)
        if config_info.has_key? 'layout' then
          @default_layout_name = config_info['layout']
        end
      end

      def load_scripts(scripts_info)
        scripts_info.each_key { |script_name|
          puts '  SCRIPT ' + script_name
          script = scripts_info[script_name]
          @scripts[script_name] = Script.new(self, script_name, script)
        }
      end

      def load_styles(styles_info)
        styles_info.each_key { |style_name|
          puts '  STYLE ' + style_name
          style = styles_info[style_name]
          @styles[style_name] = Style.new(self, style_name, style)
        }
      end
      
      def load_partials(partials_info)
        partials_info.each_key { |partial_name|
          puts '  PARTIAL ' + partial_name
          partial = partials_info[partial_name]
          @partials[partial_name] = BasePage.new(self, partial_name, partial)
        }
      end

      def load_layouts(layouts_info)
        layouts_info.each_key { |layout_name|
          puts '  LAYOUT ' + layout_name
          layout = layouts_info[layout_name]
          @layouts[layout_name] = BasePage.new(self, layout_name, layout)
        }
      end

      def load_pages(pages_info)
        pages_info.each_key { |page_name|
          puts '  PAGE ' + page_name
          page_info = pages_info[page_name]
          @pages[page_name] = Page.new(self, page_name, page_info)
        }
      end

      def render_pages()
        @pages.each_key { |page_name|
          page = @pages[page_name]
          puts '  [HAML]:' + page_name + ' => ' + page.get_page_rel_location
          self.write_file(self.results_dir, page_name + '.html', page.render_page)
        }
      end

      def render_styles()
        @styles.each_key { |style_name|
          style = @styles[style_name]
          puts '  [' + style.get_type.upcase + ']:' + style_name + ' => ' + style.get_results_path
          self.write_file(self.results_dir, style.get_results_path, style.render)
        }
      end

      def render_scripts()
        @scripts.each_key { |script_name|
          script = @scripts[script_name]
          puts '  [' + script.get_type.upcase + ']:' + script_name + ' => ' + script.get_results_path
          self.write_file(self.results_dir, script.get_results_path, script.render)
        }
      end

      # Performs the Actual Rendering of the Site
      def render()
        puts "Make and Clean Results"
        self.make_and_clean_results_dir
        puts "Loading:"
        puts "  CONFIG: site.yaml"
        site_info = YAML.load(self.read_site_file('site.yaml'))
        if site_info.has_key? 'site' then
          self.load_config(site_info['site'])
        end
        if site_info.has_key? 'scripts' then
          self.load_scripts(site_info['scripts'])
        end
        if site_info.has_key? 'styles' then
          self.load_styles(site_info['styles'])
        end
        if site_info.has_key? 'partials' then
          self.load_partials(site_info['partials'])
        end
        if site_info.has_key? 'layouts' then
          self.load_layouts(site_info['layouts'])
        end
        self.load_pages(pages_info = site_info['pages'])
        puts "Rendering:"
        self.render_pages
        self.render_styles
        self.render_scripts
      end

    end
  end
end