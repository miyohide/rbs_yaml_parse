# coding: utf-8

require 'optparse'

module RbsYamlParse
   class OptionParse
      def initialize(args)
         @args = args
      end

      def parse
         params = {}

         opt = OptionParser.new
         opt.on('-d dirname') { |v| params[:d] = v }
         opt.on('-a') { |v| params[:a] = v }
         opt.on('--maxmem') { |v| params[:maxmem] = v }
         opt.on('--minmem') { |v| params[:minmem] = v }
         opt.on('--avgmem') { |v| params[:avgmem] = v }

         opt.on('--maxtime') { |v| params[:maxtime] = v }
         opt.on('--mintime') { |v| params[:mintime] = v }
         opt.on('--avgtime') { |v| params[:avgtime] = v }

         opt.parse!(@args)

         if !params.has_key?(:d)
            raise OptionParser::ParseError
         end

         if params.has_key?(:a) && params[:a]
            params[:maxmem] = params[:minmem] =
               params[:avgmem] = params[:maxtime] =
               params[:mintime] = params[:avgtime] = true
         end

         params
      end
   end
end

