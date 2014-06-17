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
times:
- 7.745933742
- 7.694599331
- 7.693091928
- 7.70464556
- 7.698669317
memory_usages:
- 43364352
- 51826688
- 54857728
- 59854848
- 62676992
EOS
            Dir.stub_chain(:glob, :to_a, :sort).and_return(["hoge.yaml"])
            File.stub(:open).and_yield(StringIO.new(lines))
         end

         context "option is --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --mintime))
            end

            it "print min time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { mintime: 7.693091928 }}})
            end
         end

         context "option is --maxtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime))
            end

            it "print max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { maxtime: 7.745933742 }}})
            end
         end

         context "option is --avgtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgtime))
            end

            it "print avg time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { avgtime: 7.7073879756 }}})
            end
         end

         context "option is --maxtime and --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime --mintime))
            end

            it "print min and max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { mintime: 7.693091928, maxtime: 7.745933742 }}})
            end
         end

         context "option is --maxmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxmem))
            end

            it "print maxmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { maxmem: 62676992 }}})
            end
         end

         context "option is --minmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --minmem))
            end

            it "print minmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { minmem: 43364352 }}})
            end
         end

         context "option is --avgmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgmem))
            end

            it "print avgmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"hoge.yaml" => { avgmem: 54516121 }}})
            end
         end
      end

      describe "2 YAML files parse" do
         before do
            first_yaml_lines = <<EOS
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
times:
- 7.745933742
- 7.694599331
- 7.693091928
- 7.70464556
- 7.698669317
memory_usages:
- 43364352
- 51826688
- 54857728
- 59854848
- 62676992
EOS
            second_yaml_lines = <<EOS
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameters:
- 100
ruby_ver: ruby 2.0.0p123
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameter: 100
iterations: 5
max: 100.000
min: 1.123
median: 5.123
mean: 6.123
standard_deviation: 7.123
times:
- 100.000
- 7.694599331
- 7.693091928
- 7.70464556
- 1.123
memory_usages:
- 12345
- 23456
- 34567
- 45678
- 56789
EOS
            Dir.stub_chain(:glob, :to_a, :sort).and_return(["first_yaml.yaml", "second_yaml.yaml"])
            File.stub(:open).with("first_yaml.yaml").and_yield(StringIO.new(first_yaml_lines))
            File.stub(:open).with("second_yaml.yaml").and_yield(StringIO.new(second_yaml_lines))
         end

         context "option is --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --mintime))
            end

            it "print min time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { mintime: 7.693091928 }, "second_yaml.yaml" => { mintime: 1.123 }}})
            end
         end

         context "option is --maxtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime))
            end

            it "print max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { maxtime: 7.745933742 }, "second_yaml.yaml" => { maxtime: 100.000 }}})
            end
         end

         context "option is --avgtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgtime))
            end

            it "print avg time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { avgtime: 7.7073879756 }, "second_yaml.yaml" => { avgtime: 6.123 }}})
            end
         end

         context "option is --maxtime and --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime --mintime))
            end

            it "print min and max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { mintime: 7.693091928, maxtime: 7.745933742 }, "second_yaml.yaml" => { mintime: 1.123, maxtime: 100.000 }}})
            end
         end

         context "option is --maxmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxmem))
            end

            it "print maxmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { maxmem: 62676992 }, "second_yaml.yaml" => { maxmem: 56789 }}})
            end
         end

         context "option is --minmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --minmem))
            end

            it "print minmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { minmem: 43364352 }, "second_yaml.yaml" => { minmem: 12345 }}})
            end
         end

         context "option is --avgmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgmem))
            end

            it "print avgmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { avgmem: 54516121 }, "second_yaml.yaml" => { avgmem: 34567 }}})
            end
         end
      end

      describe "2 YAML files parse. 1 YAML file is error status." do
         before do
            first_yaml_lines = <<EOS
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
times:
- 7.745933742
- 7.694599331
- 7.693091928
- 7.70464556
- 7.698669317
memory_usages:
- 43364352
- 51826688
- 54857728
- 59854848
- 62676992
EOS
            second_yaml_lines = <<EOS
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameters:
- 100
ruby_ver: ruby 2.0.0p123
---
name: /home/miyoshi/ruby-benchmark-suite/benchmarks/macro-benchmarks/bm_gzip.rb
parameter: 100
status: foo bar
EOS
            Dir.stub_chain(:glob, :to_a, :sort).and_return(["first_yaml.yaml", "second_yaml.yaml"])
            File.stub(:open).with("first_yaml.yaml").and_yield(StringIO.new(first_yaml_lines))
            File.stub(:open).with("second_yaml.yaml").and_yield(StringIO.new(second_yaml_lines))
         end

         context "option is --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --mintime))
            end

            it "print min time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { mintime: 7.693091928 }, "second_yaml.yaml" => { mintime: "foo" }}})
            end
         end

         context "option is --maxtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime))
            end

            it "print max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { maxtime: 7.745933742 }, "second_yaml.yaml" => { maxtime: "foo" }}})
            end
         end

         context "option is --avgtime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgtime))
            end

            it "print avg time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { avgtime: 7.7073879756 }, "second_yaml.yaml" => { avgtime: "foo" }}})
            end
         end

         context "option is --maxtime and --mintime" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxtime --mintime))
            end

            it "print min and max time" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { mintime: 7.693091928, maxtime: 7.745933742 }, "second_yaml.yaml" => { mintime: "foo", maxtime: "foo" }}})
            end
         end

         context "option is --maxmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --maxmem))
            end

            it "print maxmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { maxmem: 62676992 }, "second_yaml.yaml" => { maxmem: "foo" }}})
            end
         end

         context "option is --minmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --minmem))
            end

            it "print minmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { minmem: 43364352 }, "second_yaml.yaml" => { minmem: "foo" }}})
            end
         end

         context "option is --avgmem" do
            before do
               @cli = RbsYamlParse::CLI.new(%w(-d foo --avgmem))
            end

            it "print avgmem" do
               @cli.run!
               expect(@cli.data).to eq({["bm_gzip.rb", 100] => {"first_yaml.yaml" => { avgmem: 54516121 }, "second_yaml.yaml" => { avgmem: "foo" }}})
            end
         end
      end

   end

end

