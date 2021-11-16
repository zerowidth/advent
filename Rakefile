require "pathname"
require "open3"

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

  puts "waiting for changes..."

  loop do
    changed = Open3.capture2("fswatch -1 -l 1 . | egrep --line-buffered '20.*/[[:digit:]]+\\.rb'").first
    to_run = changed.lines.first&.strip
    next unless to_run

    # clear iterm scrollback, makes for easy scroll-to-top when debugging
    print "\033[2J\033[3J\033[1;1H"
    running = true
    sh "ruby #{to_run}" do |ok, res|
      STDERR.puts "exit: #{res}" unless ok
      STDERR.puts
    end
    running = false
  end
end

task :clear_term do
  # clear iterm scrollback, makes for easy scroll-to-top when debugging
  print "\033[2J\033[3J\033[1;1H"
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
  src = root / "template.rb"
  last = (files.last || "00").succ
  dest = root / year / "#{last}.rb"
  input = root / year / "#{last}.txt"
  FileUtils.cp src, dest
  puts "created #{dest}"
  `pbpaste > #{input}`
  puts "created #{input}"
  `code #{dest}`
end
