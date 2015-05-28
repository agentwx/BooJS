require 'open3'
Dir.chdir File.join(File.dirname(__FILE__), '../')
require './spec/helpers'

RSpec.describe "Persist" do
  $stdout.sync = true
  it "Does accept the restart command" do
    Open3.popen3 "ruby -Ilib ./bin/boojs" do |i, o, e, t|
      begin
        i.puts "$__RESTART__"
        res = o.readline
        expect(res).to eq("$__RESTART_OK__\n")
      ensure
        begin
          Process.kill :INT, t[:pid]
        rescue Errno::ESRCH
        end
      end
    end
  end

  it "Does NOT persist during new process" do
    #Try once
    Open3.popen3 "ruby -Ilib ./bin/boojs" do |i, o, e, t|
      begin
        i.puts "localStorage.setItem('foo', 'bar');"
        i.puts "console.log(localStorage.getItem('foo'))"
        res = o.readline
        expect(res).to eq("bar\n")
      ensure
        begin
          Process.kill :INT, t[:pid]
        rescue Errno::ESRCH
        end
      end
    end

    #Try again
    Open3.popen3 "ruby -Ilib ./bin/boojs" do |i, o, e, t|
      begin
        i.puts "console.log(localStorage.getItem('foo'))"
        res = o.readline
        expect(res).to eq("null\n")
      ensure
        begin
          Process.kill :INT, t[:pid]
        rescue Errno::ESRCH
        end
      end
    end

  end

  it "Does persist during restarts" do
    Open3.popen3 "ruby -Ilib ./bin/boojs" do |i, o, e, t|
      begin
        i.puts "localStorage.setItem('foo', 'bar');"
        i.puts "$__RESTART__"
        res = o.readline
        expect(res).to eq("$__RESTART_OK__\n")

        i.puts "console.log(localStorage.getItem('foo'))"
        res = o.readline
        expect(res).to eq("bar\n")
      ensure
        begin
          Process.kill :INT, t[:pid]
        rescue Errno::ESRCH
        end
      end
    end
  end

end
