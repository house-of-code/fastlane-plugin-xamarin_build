module Fastlane
  module Actions
    class XamarinBuildAction < Action
      MDTOOL = '/Applications/Visual\ Studio.app/Contents/MacOS/vstool'.freeze
      XBUILD = '/Library/Frameworks/Mono.framework/Commands/xbuild'.freeze
      BUILD_TYPE = 'Release'
      def self.run(params)
        platform = params[:platform]
        project = params[:project]

        if params[:build_util] == 'mdtool'
          mdtool_archive_project(params, project)
        else
           puts "echo 'not supported yet'"
        end

        solution = params[:solution]
        get_build_path(platform, BUILD_TYPE, solution)
      end

      def self.mdtool_archive_project(params, project)
        platform = params[:platform]
        solution = params[:solution]
        configuration = "--configuration:#{BUILD_TYPE}|#{platform}"
        command = "#{MDTOOL} archive -p:#{project} #{solution} \"#{configuration}\""
        Helper::XamarinBuildHelper.bash(command, !params[:print_all])
      end

      # Returns bin path for given platform and build_type or nil
      def self.get_build_path(platform, build_type, solution)
        root = File.dirname(solution)

        build = Dir.glob(File.join(root, "*/bin/#{platform}/#{build_type}/"))

        if build.size > 0
          b = build[0]
          UI.message("build artifact path #{b}".blue)
          return b
        else
          return nil
        end
      end

      def self.description
        'Build xamarin android and ios projects'
      end

      def self.authors
        ['punksta']
      end

      BUILD_TYPES = %w(Release Debug).freeze
      PRINT_ALL = [true, false].freeze
      BUILD_UTIL = %w(xbuild mdtool).freeze

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :solution,
              env_name: 'FL_XAMARIN_BUILD_SOLUTION',
              description: 'path to Xamarin .sln file',
              verify_block: proc do |value|
                UI.user_error!('File not found'.red) unless File.file? value
              end
          ),

          FastlaneCore::ConfigItem.new(
            key: :platform,
            env_name: 'FL_XAMARIN_BUILD_PLATFORM',
            description: 'build platform',
            type: String
          ),

          FastlaneCore::ConfigItem.new(
            key: :print_all,
            env_name: 'FL_XAMARIN_BUILD_PRINT_ALL',
            description: 'Print std out',
            default_value: true,
            is_string: false,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{PRINT_ALL.join '\' '}".red) unless PRINT_ALL.include? value
            end
          ),

          FastlaneCore::ConfigItem.new(
              key: :project,
              env_name: 'FL_XAMARIN_BUILD_PROJECT',
              description: 'Project to build or clean',
              is_string: true,
              optional: false
          )
        ]
      end

      def self.is_supported?(platform)
        # android not tested
        [:ios].include?(platform)
      end
    end
  end
end
