require_relative "../toolkit"

# modified shunting yard algorithm
def interpret(tokens)
  values = []
  ops = []

  while (token = tokens.shift)
    debug "token: #{token}"
    case token
    when /\d+/
      if ops.last && ops.last != "("
        op = ops.pop
        case op
        when "+"
          debug "  adding"
          values << (values.pop + token.to_i)
        when "*"
          debug "  multiplying"
          values << (values.pop * token.to_i)
        else
          raise "uh? #{op} on token #{token}"
        end
      else
        debug "  pushing value"
        values << token.to_i
      end
    when "+", "*", "("
      debug "  pushing operation"
      ops << token
    when ")"
      if ops.last == "("
        ops.pop
      else
        raise "mismatched paren?!"
      end

      # clear the op queue
      while ops.last && ops.last != "("
        op = ops.pop
        case op
        when "+"
          debug "  adding"
          values << (values.pop + values.pop)
        when "*"
          debug "  multiplying"
          values << (values.pop * values.pop)
        else
          raise "fhghuh? #{op} on token #{token}"
        end
      end
    else
      raise "wtf: #{token}"
    end
    debug "  values #{values} ops #{ops}"
  end

  values.last
end

# instead of worrying about operator precedence, just add parens around each
# addition so it's always evaluated before a multiplication.
# ref: https://en.wikipedia.org/wiki/Operator-precedence_parser#Alternative_methods
# 
# * replace + and – with ))+(( and ))-((, respectively;
# * replace * and / with )*( and )/(, respectively;
# * add (( at the beginning of each expression and after each left parenthesis in the original expression; and
# * add )) at the end of the expression and before each right parenthesis in the original expression.
#
# modifying this so + has priority over *:
def rewrite(tokens)
  rewritten = ["(", "("]
  tokens.each do |token|
    case token
    when "+"
      rewritten << ")" << token << "("
    when "*"
      rewritten << ")" << ")" << token << "(" << "("
    when "("
      rewritten << token << "(" << "("
    when ")"
      rewritten << ")" << ")" << token
    else
      rewritten << token
    end
  end
  rewritten << ")" << ")"
end

def part1(input)
  input.each_line.map(&:strip).map do |expr|
    tokens = expr.scan(/[()*+]|\d+/)
    debug "#{expr} #{tokens}"
    interpret(tokens)
  end.sum
end

def part2(input)
  input.each_line.map(&:strip).map do |expr|
    tokens = expr.scan(/[()*+]|\d+/)
    debug "expr      #{expr}"
    debug "tokens    #{tokens}"
    rewritten = rewrite(tokens)
    debug "rewritten #{rewritten.join(" ")}"
    debug "          #{rewritten}"
    interpret(rewritten)
  end.sum
end

ex1 = <<-EX
1 + 2 * 3 + 4 * 5 + 6
EX

ex2 = <<EX
1 + (2 * 3) + (4 * (5 + 6))
EX

ex3 = "2 * 3 + (4 * 5)"
ex4 = "5 + (8 * 3 + 9 + 3 * 4 * 3)"
ex5 = "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
ex6 = "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"

part 1
with :part1
debug!
try ex1, expect: 71
try ex2, expect: 51
no_debug!
try ex3, expect: 26
try ex4, expect: 437
try ex5, expect: 12240
try ex6, expect: 13632
try puzzle_input

part 1
with :part2
debug!
try ex1, expect: 231
try ex2, expect: 51
no_debug!
try ex3, expect: 46
try ex4, expect: 1445
try ex5, expect: 669060
try ex6, expect: 23340
try puzzle_input
