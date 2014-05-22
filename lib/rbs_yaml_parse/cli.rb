module RbsYamlParse
   class CLI

      attr_reader :filename

      def initialize(args)
         @filename = args[0] if args.size > 0
      end

      def run
         f = File.open(@filename)
         parse_results = YAML.load_stream(f)
         f.close

         exec_info = parse_results.shift

         print_list = []
         parse_results.each do |parse_result|
            next if parse_result.has_key?("status")

            one_line = []
            one_line << parse_result["name"]
            one_line << parse_result["parameter"]
            one_line << parse_result["max"]
            one_line << parse_result["min"]

            memory_usages = parse_result["memory_usages"]
            one_line << memory_usages.inject(0) { |i, sum| i + sum } / memory_usages.size
            print_list << one_line
         end

         print_list.each do |line|
            print line.to_csv
         end
         0
      end

   end
end

