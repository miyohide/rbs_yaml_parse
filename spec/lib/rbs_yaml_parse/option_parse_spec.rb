# coding: utf-8

require 'spec_helper'

describe RbsYamlParse::OptionParse do
   it "parse success" do
      parser = RbsYamlParse::OptionParse.new(%w(-d dirname -a --maxmem --minmem --avgmem --maxtime --mintime --avgtime))

      parse_result = parser.parse

      expect(parse_result).to include(d: "dirname")
      expect(parse_result).to include(a: true)
      expect(parse_result).to include(maxmem: true)
      expect(parse_result).to include(minmem: true)
      expect(parse_result).to include(avgmem: true)

      expect(parse_result).to include(maxtime: true)
      expect(parse_result).to include(mintime: true)
      expect(parse_result).to include(avgtime: true)
   end

   it "parse fail (option unknown)" do
      parser = RbsYamlParse::OptionParse.new(%w(-d dirname -a --hogehoge))

      expect { parser.parse }.to raise_error(OptionParser::InvalidOption)


   end
end

