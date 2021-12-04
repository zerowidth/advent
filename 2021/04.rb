require_relative "../toolkit"

class Board

  attr_reader :rows, :marked

  def initialize(input)
    @rows = input.lines_of(:numbers)
    @marked = {}
  end

  def mark(num)
    rows.each.with_index do |nums, row|
      if (col = nums.index(num))
        marked[[row, col]] = true
      end
    end
  end

  def bingo?
    size = rows.first.length
    # any row entirely marked
    return true if marked.keys.tally_by(&:first).any? { |row, count| count == size }

    # any column
    return true if marked.keys.tally_by(&:last).any? { |row, count| count == size }

    false
  end

  def score
    # sum of unmarked numbers
    rows.flat_map.with_index do |nums, row|
      nums.reject.with_index do |_num, col|
        marked[[row, col]]
      end
    end.sum
  end

  def to_s
    rows.map.with_index do |nums, row|
      nums.map.with_index do |num, col|
        num = num.to_s.rjust(2)
        num = num.colorize(:red) if @marked[[row, col]]
        num
      end.join(" ")
    end.join("\n")
  end
end



def draw(board)
  debug "---"
  debug board.to_s
end

def part1(input)
  numbers = input.sections.first.numbers
  boards = input.sections.drop(1).map do |board|
    Board.new(board)
  end

  winner = numbers.detect do |drawn|
    debug "drew #{drawn}"
    boards.each { |b| b.mark drawn }
    # boards.map_with(:draw)

    boards.any?(&:bingo?)
  end

  board = boards.detect(&:bingo?)
  draw(board)
  board.score * winner
end

def part2(input)
  numbers = input.sections.first.numbers
  boards = input.sections.drop(1).map do |board|
    Board.new(board)
  end

  debug "boards: #{boards}"

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
  draw board

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
