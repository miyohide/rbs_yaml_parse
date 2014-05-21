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

         parse_results.each do |parse_result|
            puts parse_result["memory_usages"].inspect
         end

         0
      end

   end
end

