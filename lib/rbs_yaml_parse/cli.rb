require 'yaml'

module RbsYamlParse
   class CLI

      PARAM_KEYS = [:mintime, :maxtime, :avgtime, :maxmem, :minmem, :avgmem]
      attr_reader :data

      def initialize(command_args)
         @option_parser = OptionParse.new(command_args)
         @data = Hash.new { |h,k| h[k] = {} }
         @yaml_files = []
         @params = []
      end

      def run!
         @params = @option_parser.parse

         filepath = File.join(@params[:d], "**/*.yaml")
         @yaml_files = Dir.glob(filepath).to_a.sort

         @yaml_files.each do |yaml_file|
            File.open(yaml_file) { |file|
               YAML.load_documents(file) do |doc|
                  next if doc["parameter"].nil?
                  key = [File.basename(doc["name"]), doc["parameter"]]

                  @data[key][yaml_file] = val_map(doc, @params)
               end
            }
         end
      end

      def val_map(yaml_doc, params)
         val = {}

         PARAM_KEYS.each do |param_key|
            val[param_key] = data_or_status(yaml_doc, param_key) if params[param_key]
         end
         val
      end

      def output_data(params)
         PARAM_KEYS.each do |params_key|
            next unless params.has_key?(params_key)

            @data.keys.each do |data_key|
               puts create_one_line(params_key.to_s, data_key)
            end
         end
      end

      def data_or_status(yaml_doc, data_name)
         option2yaml_key = {mintime: "min", maxtime: "max", avgtime: "mean"}
         case data_name
         when :mintime, :maxtime, :avgtime
            yaml_doc[option2yaml_key[data_name]].nil? ? modified_status(yaml_doc["status"]) : yaml_doc[option2yaml_key[data_name]]
         when :maxmem
            yaml_doc["memory_usages"].nil? ? modified_status(yaml_doc["status"]) : yaml_doc["memory_usages"].max
         when :minmem
            yaml_doc["memory_usages"].nil? ? modified_status(yaml_doc["status"]) : yaml_doc["memory_usages"].min
         when :avgmem
            yaml_doc["memory_usages"].nil? ? modified_status(yaml_doc["status"]) : yaml_doc["memory_usages"].inject(0) { |sum, mem| sum + mem } / yaml_doc["memory_usages"].size
         end
      end

      def modified_status(status_data)
         status_data.nil? ? "" : status_data.split(" ", 2)[0]
      end

      def create_one_line(key, data_key)
         key_line = data_key.join(",")

         data_line = @yaml_files.inject("") do |sum, yaml_file|
            unless @data[data_key][yaml_file].nil?
               "#{sum}#{@data[data_key][yaml_file][key.to_sym].to_s},"
            else
               "#{sum},"
            end
         end

         # delete last comma(,)
         "#{key_line},#{data_line}".gsub(/,+\Z/, '')
      end

      def csv_header(val)
         "program,params,#{val.to_s*@yaml_files.size}"
      end

      def file_output
         PARAM_KEYS.each do |params_key|
            file_name = "result_#{params_key}.csv"
            File.open(file_name, "w") { |file|
               file.write "#{csv_header(params_key)}\n"
               next unless @params.has_key?(params_key)

               @data.keys.each do |data_key|
                  file.write "#{create_one_line(params_key.to_s, data_key)}\n"
               end
            }
         end

      end
   end
end

