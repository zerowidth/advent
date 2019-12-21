require "pathname"

task default: %w(latest)

def year
  ENV.fetch("year", Time.now.year.to_s)
end

def root
  Pathname.new File.dirname(__FILE__)
end

def files_for_year
  (root / year).children.select { |f| f.basename.to_s =~ /\d{2}.rb/ }
end

def day_file
  if day = ENV["day"]
    file = (root / year) / ("%02d.rb" % day)
  else
    file = files_for_year.sort.last
  end
  file.to_s
end


desc "Run the latest puzzle (default). Specify `year=YYYY` to set the year."
task :latest do
  sh "ruby", day_file
end

desc "Watch the latest puzzle for changes"
task :watch do
  sh "fswatch #{day_file} | xargs -n1 ruby"
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
  files = files_for_year.sort.map {|f| File.basename(f, ".rb") }
  src = root / "template.rb"
  dest = root / year / (files.last.succ + ".rb")
  input = root / year / (files.last.succ + ".txt")
  FileUtils.cp src, dest
  puts "created #{dest}"
  `pbpaste > #{input}`
  puts "created #{input}"
end
