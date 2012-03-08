require_relative 'helper'
require "harbor/commands/setup"

class HarborSetupCommandTest < MiniTest::Unit::TestCase

  def after_tests
    destroy_petshop if @petshop_generated
  end

  def setup
    generate_petshop unless @petshop_generated
  end

  def generate_petshop
    @temp_path = ::File.join(::File.dirname(__FILE__), "tmp")
    destroy_petshop

    @app_root = ::File.join(@temp_path, "petshop")
    FileUtils.mkdir_p(@app_root)

    Harbor::Commands::Setup.new('petshop', @app_root, nil).run

    @petshop_generated = true
  end

  def destroy_petshop
    FileUtils.rm_rf(@temp_path) if ::File.directory?(@temp_path)
  end

  def test_generator_creates_expected_app_structure
    expected_generated_file_and_directory_list = %w{
      petshop/Gemfile
      petshop/config.ru
      petshop/controllers
      petshop/controllers/home.rb
      petshop/env
      petshop/env/default.rb
      petshop/env/development.rb
      petshop/env/stage.rb
      petshop/env/testing.rb
      petshop/env/production.rb
      petshop/forms
      petshop/forms/example.rb
      petshop/helpers
      petshop/helpers/general.rb
      petshop/lib
      petshop/lib/boot.rb
      petshop/lib/petshop.rb
      petshop/log
      petshop/models
      petshop/public
      petshop/public/images
      petshop/public/javascripts
      petshop/public/stylesheets
      petshop/views
      petshop/views/layouts
      petshop/views/layouts/application.html.erb
      petshop/views/home
      petshop/views/home/index.html.erb
    }

    skeleton = Dir["#{@app_root}/**/*"].map { |path| path.sub "#{@temp_path}/", "" }
    assert_equal expected_generated_file_and_directory_list.sort, skeleton.sort
  end

  def test_generator_creates_proper_home_rb
    assert_generated_file_matches "controllers/home.rb", <<-RUBY
      class Petshop
        class Home < Harbor::Controller

          get "/" do
            response.render "home/index"
          end

        end
      end
    RUBY
  end

  def test_generator_creates_proper_petshop_rb
    assert_generated_file_matches "lib/petshop.rb", <<-RUBY
      require "rubygems"
      require "bundler/setup"
      require "harbor"

      config.load!(Pathname(__FILE__).dirname.parent + "env")

      class Petshop < Harbor::Application

        def initialize
          # Any code you need to initialize your application goes here.
        end

      end

      require_relative "../controllers/home"
    RUBY
  end

  def test_generator_creates_proper_boot_rb
    assert_generated_file_matches "lib/boot.rb", <<-RUBY
      require "lib/petshop"
    RUBY
  end

  private

  def assert_generated_file_matches(relative_file_path, expected_result)
    path = ::File.join(@app_root, relative_file_path)

    assert ::File.file?(path), "Generated File \"#{path}\" not found."
    assert_equal expected_result.margin, ::File.read(path).strip
  end

end