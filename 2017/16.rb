require_relative "../toolkit"

def solution(input, programs, dances=1)
  puts
  partners = ("a".."p").to_a[0...programs]

  moves = input.strip.split(",").map do |move|
    m, rest = move[0], move[1..-1]
    case m
    when "s"
      [:s, rest.to_i]
    when "x"
      a, b = rest.split("/").map(&:to_i)
      [:x, a, b]
    when "p"
      a, b = rest.split("/")
      [:p, a, b]
    end
  end

  seen = Set.new
  n = 0
  while n < dances
    moves.each do |move|
      case move[0]
      when :s
        partners.rotate!(-move[1])
      when :x
        a, b = move[1], move[2]
        partners[a], partners[b] = partners[b], partners[a]
      when :p
        a, b = move[1], move[2]
        ai = partners.index a
        bi = partners.index b
        if ai.nil? || bi.nil?
          puts "??? move #{move.inspect}"
        end
        partners[ai], partners[bi] = partners[bi], partners[ai]
      else
        raise "what? #{move}"
      end
    end
    if seen.include? partners
      puts "found repeat on dance #{n}, only #{dances % n} left"
      n = dances - (dances % n) + 1
      seen.clear
      next
    else
      seen << partners
    end
    print "\r#{n} " if n % 10 == 0
    n += 1
  end

  partners.join("")
end

example = <<-EX
s1,x3/4,pe/b
EX

part 1
with(:solution, 5)
try example, "baedc"
with(:solution, 16)
try puzzle_input

part 2
with(:solution, 5, 2)
try example, "ceadb"
with(:solution, 5, 22)
try "s1", "deabc"
with(:solution, 16, 1_000_000_000)
try puzzle_input
