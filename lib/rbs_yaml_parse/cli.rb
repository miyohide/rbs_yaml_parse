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

                  @data[key][yaml_file] = val_map(doc, params)
               end
            }
         end

         output_data(params, yaml_files)
      end

      def val_map(yaml_doc, params)
         val = {}
         if params[:mintime]
            val[:mintime] = yaml_doc["min"]
         end

         if params[:maxtime]
            val[:maxtime] = yaml_doc["max"]
         end

         if params[:avgtime]
            val[:avgtime] = yaml_doc["mean"]
         end

         if params[:maxmem]
            val[:maxmem] = yaml_doc["memory_usages"].max
         end

         if params[:minmem]
            val[:minmem] = yaml_doc["memory_usages"].min
         end

         if params[:avgmem]
            val[:avgmem] = yaml_doc["memory_usages"].inject(0) { |sum, mem| sum + mem } / yaml_doc["memory_usages"].size
         end
         val
      end

      def output_data(params, yaml_files)
         params_keys = %w[mintime maxtime avgtime minmem maxmem avgmem]

         params_keys.each do |params_key|
            next unless params.has_key?(params_key.to_sym)

            @data.keys.each do |data_key|
               one_line = data_key.join(",")

               one_line = yaml_files.inject(one_line + ",") do |sum, yaml_file|
                  sum + @data[data_key][yaml_file][params_key.to_sym].to_s + ","
               end

               # delete last comma(,)
               one_line.gsub!(/,+\Z/, '')

               puts one_line
            end
         end
      end
   end
end

