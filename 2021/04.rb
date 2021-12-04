require_relative "../toolkit"

class Board
  attr_reader :rows, :marked

  def initialize(input)
    @rows = input.lines_of(:numbers)
    @marked = Set.new
  end

  def lines
    @lines ||= (rows + rows.first.zip(*rows.drop(1))).map(&:to_set)
  end

  def mark(num)
    marked << num
  end

  def bingo?
    lines.any? { |line| line.subset? marked }
  end

  def score
    # sum of unmarked numbers
    rows.flat_map do |row|
      row.reject do |num|
        marked.include?(num)
      end
    end.sum
  end

  def draw
    str = rows.map do |row|
      row.map do |num|
        s = num.to_s.rjust(2)
        s = s.colorize(:red) if marked.include?(num)
        s
      end.join(" ")
    end.join("\n")
    debug str
    debug "---"
  end
end


def part1(input)
  numbers = input.sections.first.numbers
  boards = input.sections.drop(1).map do |board|
    Board.new(board)
  end

  winner = numbers.detect do |drawn|
    debug "drew #{drawn}"
    boards.each { |b| b.mark drawn }
    boards.any?(&:bingo?)
  end

  debug "BINGO!"
  board = boards.detect(&:bingo?)
  board.draw
  board.score * winner
end

def part2(input)
  numbers = input.sections.first.numbers
  boards = input.sections.drop(1).map do |board|
    Board.new(board)
  end

  while (drawn = numbers.shift)
    debug "drew #{drawn}"
    boards.each { |b| b.mark drawn }

    winners = boards.select(&:bingo?)
    if winners.any?
      debug "removing #{winners.length} boards, #{boards.length - winners.length} remain"
      boards -= winners
    end

    break if boards.length == 1
  end

  board = boards.first
  debug "last board, drew #{drawn}"
  board.draw

  until board.bingo? || numbers.empty?
    drawn = numbers.shift
    debug "drew #{drawn}"
    board.mark drawn
  end

  board.score * drawn
end

ex1 = <<EX
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
EX

part 1
with :part1
debug!
try ex1, 4512
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, 1924
no_debug!
try puzzle_input
