require 'yaml'

module RbsYamlParse
   class CLI

      attr_reader :data

      def initialize(command_args)
         @option_parser = OptionParse.new(command_args)
         @data = Hash.new { |h,k| h[k] = {} }
      end

      def run!
         params = @option_parser.parse

         filepath = File.join(params[:d], "**/*.yaml")
         yaml_files = Dir.glob(filepath).to_a.sort

         yaml_files.each do |yaml_file|
            File.open(yaml_file) { |file|
               YAML.load_documents(file) do |doc|
                  next if doc["min"].nil?
                  key = [File.basename(doc["name"]), doc["parameter"]]

                  @data[key][yaml_file]    = doc["min"]
               end
            }
         end

         @data.keys.each do |k|
            one_line = k.join(",")

            one_line = yaml_files.inject(one_line + ",") do |sum, yaml_file|
               sum + @data[k][yaml_file].to_s + ","
            end

            one_line.gsub!(/,+\Z/, '')

            puts one_line
         end
      end
   end
end

