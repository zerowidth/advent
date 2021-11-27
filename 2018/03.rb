require_relative "../toolkit"

def overlapping(input)
  claims = input.split("\n").map do |line|
    line.scan(/\d+/).drop(1).map(&:to_i)
  end
  fabric = Hash.new(0)
  claims.each do |sx, sy, w, h|
    (sx...sx + w).each do |x|
      (sy...sy + h).each do |y|
        fabric[[x, y]] += 1
      end
    end
  end
  fabric.values.count { |v| v > 1 }
end

ex1 = <<-EX
#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
EX

# start at a, width aw, start b, width bw
def overlap?(a, aw, b, bw)
  a2 = a + aw
  b2 = b + bw
  # b starts inside a || a starts inside b || a and b start at the same pos
  (b > a && b < a2) || (a > b && a < b2) || (a == b)
end

def unique_claim(input)
  claims = input.split("\n").map do |line|
    line.scan(/\d+/).map(&:to_i)
  end
  dpp claims

  alone = claims.reject do |claim|
    cid, cx, cy, cw, ch = *claim
    debug "checking #{claim}"
    claims.any? do |candidate|
      id, x, y, w, h = *candidate
      next if cid == id

      if overlap?(cx, cw, x, w) && overlap?(cy, ch, y, h)
        debug "  #{candidate} overlaps"
        true
      else
        debug "  #{candidate} no overlap"
      end
    end
  end

  puts "alone: #{alone}"
  alone = alone.first if alone.any?
  # fabric_claims = Hash.of_array
  # claims.each.with_progress(total: claims.length) do |claim|
  #   id, sx, sy, w, h = *claim
  #   (sx...sx + w).each do |x|
  #     (sy...sy + h).each do |y|
  #       fabric_claims[[x, y]] << id
  #     end
  #   end
  # end

  # # now, find all claims which don't overlap
  # separate = Set.new(claims.map(&:first))
  # fabric_claims.values.each.with_progress(total: fabric_claims.length) do |vs|
  #   separate = separate.difference(vs) if vs.length > 1
  # end
  # separate.first
  alone&.at(0)
end

part 1
debug!
with :overlapping
try ex1, expect: 4
no_debug!
try puzzle_input

part 2
with :unique_claim
debug!
try ex1, expect: 3
no_debug!
try puzzle_input
