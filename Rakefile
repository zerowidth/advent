require "bundler"
Bundler.setup
require "colorize"

require "net/http"
require "pathname"
require "pty"

task default: %w[latest]

def year
  now = Time.now
  default = if now.month == 12
    now.year
  else
    now.year.to_i - 1
  end
  ENV.fetch("year", default.to_s)
end

def root
  Pathname.new File.dirname(__FILE__)
end

def files_for_year
  FileUtils.mkdir_p(root / year)
  (root / year).children.select { |f| f.basename.to_s =~ /\d{2}.rb/ }
end

def day_file
  file = if (day = ENV["day"])
    (root / year) / ("%02d.rb" % day)
  else
    files_for_year.max
  end
  file.to_s
end

desc "Run the latest puzzle (default). Specify `year=YYYY` to set the year."
task :latest do
  sh "ruby", day_file
end

# Waits for the first matching file, then yields it.
# Once the block returns, clear any remaining reads, then repeat the loop.
def on_file_change(pattern)
  # 2-second latency because vscode touches a saved file twice
  # ref: https://github.com/nodejs/node/issues/6112
  PTY.spawn("fswatch .") do |stdout, stdin, _pid|
    stdin.close

    loop do
      # print this once at the beginning of each loop
      puts "waiting for changes...".colorize(:cyan)

      # wait for a matching file
      while (line = stdout.gets.strip)
        break if line =~ pattern
      end

      yield line

      # flush any events that happened in the meantime
      stdout.gets while IO.select([stdout], [], [], 0)
    end
  end
end

desc "Watch the latest puzzle for changes"
task :watch do
  running = false

  Signal.trap("INT") do
    if running
      running = false
    else
      exit 1
    end
  end

  last = nil
  on_file_change(/\.rb$/) do |file|
    matched = file =~ %r{\d{4}/\d{2}\.rb}

    # clear iterm scrollback, makes for easy scroll-to-top when debugging
    print "\033[2J\033[3J\033[1;1H" if matched || last

    if matched
      last = file
    elsif last
      puts "#{file} changed, rerunning last"
    else
      next
    end

    running = true
    sh "ruby #{last}" do |ok, res|
      warn res.to_s.colorize(:red) unless ok
      puts
    end
    running = false
  end
end

desc "Run all puzzles for the given or current year. Specify `year=2017` to set the year."
task :all do
  files_for_year.sort.each do |file|
    puts "-" * 80
    sh "ruby", file.to_s
  end
end

desc "Create the next one"
task :next do
  files = files_for_year.sort.map { |f| File.basename(f, ".rb") }
  template = root / "template.rb"
  last = (files.last || "00").succ
  script = root / year / "#{last}.rb"
  input = root / year / "#{last}.txt"

  unless ENV["ADVENT_SESSION"]
    puts "ADVENT_SESSION not set!"
    exit 1
  end

  uri = URI("https://adventofcode.com/#{year}/day/#{last.to_i}/input")
  req = Net::HTTP::Get.new(uri)
  req["Cookie"] = "session=#{ENV["ADVENT_SESSION"]}"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

  unless res.code == "200"
    puts "input fetch failed!"
    puts res.inspect
    exit 1
  end

  FileUtils.cp template, script
  puts "created #{script}"
  File.open(input, "w") { |f| f.write res.body }
  puts "created #{input}"
  sh "git add -N #{script}"
  sh "git add #{input}"
  sh "code #{input}"
  sh "code #{script}"
end
