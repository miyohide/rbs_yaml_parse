# coding: utf-8

require 'spec_helper'

describe RbsYamlParse::CLI do
   describe "run!" do
      context "No args" do
         before do
            @cli = RbsYamlParse::CLI.new([])
         end

         it "Option Error" do
            expect{@cli.run!}.to raise_error(OptionParser::ParseError)
         end
      end

      context "-d option" do
         before do
            @cli = RbsYamlParse::CLI.new(%w(-d nothing_data_directory))
         end

         it "Not raise Error" do
            expect{@cli.run!}.not_to raise_error
         end
      end

      describe "YAML parse" do
         before do
            @cli = RbsYamlParse::CLI.new(%w(-d foo))
            lines = <<EOS
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameters:
- 100
ruby_ver: ruby 2.1.2p95
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameter: 100
iterations: 5
max: 7.745933742
min: 7.693091928
median: 7.698669317
mean: 7.7073879756
standard_deviation: 0.01968369053890256
EOS
            Dir.stub_chain(:glob, :to_a, :sort).and_return(["hoge.yaml"])
            File.stub(:open).and_yield(StringIO.new(lines))
         end

         it "yaml parse result" do
            @cli.run!
            expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => 7.693091928}})
         end
      end

   end

end
