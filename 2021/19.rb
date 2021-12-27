require_relative "../toolkit"

TWO_D_ROTATIONS = [
  Matrix[[1, 0], [0, 1]], # x y
  Matrix[[1, 0], [0, -1]], # x -y
  Matrix[[-1, 0], [0, 1]], # -x y
  Matrix[[-1, 0], [0, -1]], # -x -y
  Matrix[[0, 1], [1, 0]], # y x
  Matrix[[0, 1], [-1, 0]], # y -x
  Matrix[[0, -1], [1, 0]], # -y x
  Matrix[[0, -1], [-1, 0]], # -y -x
]

THREE_D_ROTATIONS = [
  # z = z
  Matrix[[1, 0, 0], [0, 1, 0], [0, 0, 1]], # x = x, y = y
  Matrix[[0, 1, 0], [-1, 0, 0], [0, 0, 1]], # x = y, y = -x
  Matrix[[-1, 0, 0], [0, -1, 0], [0, 0, 1]], # x = -x, y = -y
  Matrix[[0, -1, 0], [1, 0, 0], [0, 0, 1]], # x = -y, y = x

  # z = -z
  Matrix[[1, 0, 0], [0, -1, 0], [0, 0, -1]], # x = x, y = -y
  Matrix[[0, -1, 0], [-1, 0, 0], [0, 0, -1]], # x = -y, y = -x
  Matrix[[-1, 0, 0], [0, 1, 0], [0, 0, -1]], # x = -x, y = y
  Matrix[[0, 1, 0], [1, 0, 0], [0, 0, -1]], # x = y, y = x

  # z = x
  Matrix[[0, 0, -1], [0, 1, 0], [1, 0, 0]], # x = -z, y = y
  Matrix[[0, 1, 0], [0, 0, 1], [1, 0, 0]], # x = y, y = z
  Matrix[[0, 0, 1], [0, -1, 0], [1, 0, 0]], # x = z, y = -y
  Matrix[[0, -1, 0], [0, 0, -1], [1, 0, 0]], # x = -y, y = -z

  # z = -x
  Matrix[[0, 0, -1], [0, -1, 0], [-1, 0, 0]], # x = -z, y = -y
  Matrix[[0, -1, 0], [0, 0, 1], [-1, 0, 0]], # x = -y, y = z
  Matrix[[0, 0, 1], [0, 1, 0], [-1, 0, 0]], # x = z, y = y
  Matrix[[0, 1, 0], [0, 0, -1], [-1, 0, 0]], # x = y, y = -z

  # z = y
  Matrix[[1, 0, 0], [0, 0, -1], [0, 1, 0]], # x = x, y = -z
  Matrix[[0, 0, -1], [-1, 0, 0], [0, 1, 0]], # x = -z, y = -x
  Matrix[[-1, 0, 0], [0, 0, 1], [0, 1, 0]], # x = -x, y = z
  Matrix[[0, 0, 1], [-1, 0, 0], [0, 1, 0]], # x = z, y = -x

  # z = -y
  Matrix[[1, 0, 0], [0, 0, 1], [0, -1, 0]], # x = x, y = z
  Matrix[[0, 0, 1], [-1, 0, 0], [0, -1, 0]], # x = z, y = -x
  Matrix[[-1, 0, 0], [0, 0, -1], [0, -1, 0]], # x = -x, y = -z
  Matrix[[0, 0, -1], [1, 0, 0], [0, -1, 0]], # x = -z, y = x
]

class Array
  def rotate(rotation)
    (rotation * Matrix.column_vector(self)).column(0).to_a
  end

  def unrotate(rotation)
    (rotation.transpose * Matrix.column_vector(self)).column(0).to_a
  end

  def translate(dir)
    zip(dir).map { |me, d| me + d }
  end

  def sub(dir)
    zip(dir).map { |me, d| me - d }
  end
end

class Scanner
  attr_reader :num, :relative_locations, :beacons, :spaces, :position, :rotation

  def initialize(num, relative_locations, rotations:)
    @num = num
    @relative_locations = relative_locations
    @rotations = rotations
    @spaces = Hash.of_array
    @rotations.each do |rotation|
      rotated = relative_locations.map { |b| b.rotate(rotation) }
      rotated.each do |beacon|
        # store map of rotation matrix to lists of beacons with relative positioning in the new rotated frame
        # TODO are all these needed? lazily calculate? don't need at all?
        @spaces[rotation] << rotated.map { |other| other.sub(beacon) }
      end
    end
  end

  def located?
    !!@position
  end

  def locate(position, rotation)
    @position = position
    @rotation = rotation

    # store beacons absolutely positioned:
    @beacons = @relative_locations.map do |beacon|
      beacon.rotate(rotation).translate(position)
    end
    debug { "scanner #{num} located at #{position} with rotation #{rotation}".colorize(:yellow) }
  end

  def overlap?(other, minimum:)
    # find first scanner which has an overlapping beacon space with another
    debug { "comparing scanner #{num} to scanner #{other.num}".colorize(:blue) }

    # used fixed zero relative reference orientation, we can orient the other to match
    # and then locate from there:
    spaces.values.first.each do |bspace|
      # debug { "  relative_locations:       #{relative_locations}" }
      other.spaces.each do |orotation, ospaces|
        ospaces.each do |ospace|
          overlap = bspace & ospace
          next unless overlap.length >= minimum

          # our beacon space at zero absolute rotation overlaps
          # the other beacon space with another rotation.
          debug { "  bspace:                   #{bspace.first(minimum)}" }
          debug { "  ospace:                   #{ospace.first(minimum)}" }
          debug { "  overlap:                  #{overlap}" }
          debug { "  orotation:                #{orotation}" }
          # debug { "  other.relative_locations  #{other.relative_locations}" }
          # debug { "  other.relative unrotated: #{other.relative_locations.map { |o| o.unrotate(orotation) }}" }
          # debug do
            # "  rotated overlap:          #{rotated}"
          # end

          # the first overlapping beacon, relative to this scanner's location/rotation:
          this_beacon = relative_locations[bspace.index(overlap.first)]
          debug { "  this beacon (relative):   #{this_beacon}" }

          # the other beacon's relative position in its scanner's zero rotation.
          # but we know it only matches when rotated to `orotation`
          other_beacon = other.relative_locations[ospace.index(overlap.first)].rotate(orotation)
          debug { "  other (relative):         #{other_beacon}" }

          # now find the relative scanner position based on the difference:
          relative = this_beacon.sub(other_beacon)
          debug { "  relative pos: #{relative}" }
          # unrotate to get back to absolute positioning
          relative = relative.unrotate(rotation)
          debug { "  relative pos (absolute): #{relative}" }
          debug { "  position: #{position}" }

          # convert relative distance to absolute:
          pos = position.translate(relative)
          debug { "  pos (translated): #{pos}" }

          # get the final combined rotation for the other scanner
          orotation = rotation * orotation

          # debugging: grab the (relative) overlapping positions:
          debug do
            obs = overlap.map do |o|
              pos.translate(other.relative_locations[ospace.index(o)].rotate(orotation))
            end
            "  overlapping (absolute): #{obs}"
          end

          return pos, orotation
        end
      end
    end
    nil
  end

  def to_s
    "<S #{num}: pos: #{position || "?"} rot: #{rotation || "?"}>"
  end
end

def overlaps(input)
  rotations = TWO_D_ROTATIONS
  scanners = input.sections.with_progress(title: "loading beacons").map.with_index do |section, i|
    beacons = section.lines.drop(1).map(&:signed_numbers)
    Scanner.new(i, beacons, rotations: rotations)
  end

  # debug { "scanners[0].spaces:\n#{scanners[0].spaces.pretty_inspect}" }
  # debug { "scanners[1].spaces:\n#{scanners[1].spaces.pretty_inspect}" }
  # debug { "scanners[2].spaces:\n#{scanners[2].spaces.pretty_inspect}" }

  scanners.first.locate([0] * rotations.first.column(0).to_a.length, rotations.first)
  debug { "scanners[0].beacons: #{scanners[0].beacons}" }

  # this one's easy, it's relative to zero/zero:
  if (pos, rot = scanners[0].overlap?(scanners[1], minimum: 2))
    debug { "pos: #{pos} rot: #{rot}" }
    scanners[1].locate(pos, rot)
    debug { "  scanners[1].beacons: #{scanners[1].beacons}" }
  end

  # a rotated scanner matching another, differently-rotated scanner:
  # this is where the bugs are.
  if (pos, rot = scanners[1].overlap?(scanners[2], minimum: 2))
    scanners[2].locate(pos, rot)
    debug { "  scanners[2].beacons: #{scanners[2].beacons}" }
  end

  [scanners.map(&:position), scanners.map(&:beacons).reduce(&:&).sort]
end

def part1(input, rotations:, minimum:)
  scanners = input.sections.with_progress(title: "loading beacons").map.with_index do |section, i|
    beacons = section.lines.drop(1).map(&:signed_numbers)
    Scanner.new(i, beacons, rotations: rotations)
  end
  scanners.first.locate([0] * rotations.first.column(0).to_a.length, rotations.first)

  to_match = scanners.reject(&:located?)
  compared = Set.new # don't compare twice!

  until to_match.empty?
    # see if we can match:
    matched = false
    scanners.select(&:located?).each do |scanner|
      to_match.each do |candidate|
        key = [scanner.num, candidate.num]

        next if compared.include?(key)

        compared << key

        next unless (pos, rot = scanner.overlap?(candidate, minimum: minimum))

        matched = true
        debug "matched #{scanner.num} to #{candidate.num}"
        candidate.locate(pos, rot)
        to_match.delete(candidate)
      end
      break if matched
    end
    break unless matched # escape hatch if infinite loop
  end

  debug "scanners:\n#{scanners.map(&:position).pretty_inspect}"

  beacons = scanners.flat_map(&:beacons).uniq
  debug "beacons:\n  #{beacons.sort.map(&:to_s).join("\n  ")}"
  beacons.length
end

def part2(input)
  input.lines
end

ex1 = <<EX
--- scanner 0 ---
0,2
4,1
3,3

--- scanner 1 ---
-1,-1
-5,0
-2,1
EX

manual = <<EX
scanner 0: [0, 0], no rotation
1,2
3,3
4,4

scanner 1: [0, 4] with [y, x]
-2,1
-1,3
0,4

scanner 2: [4, 0] with [-x, y]
3,2
1,3
0,4
EX

ex2 = <<EX
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
EX

part 1
debug!

with :overlaps
try manual, [[[0, 0], [0, 4], [4, 0]], [[1, 2], [3, 3], [4, 4]]]
with :part1, rotations: TWO_D_ROTATIONS, minimum: 3
debug!
try ex1, 3
with :part1, rotations: THREE_D_ROTATIONS, minimum: 12
try ex2, 79
# no_debug!
try puzzle_input

# part 2
# with :part2
# debug!
# try ex1, nil
# no_debug!
# try puzzle_input
