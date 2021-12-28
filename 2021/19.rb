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
    rotate(rotation.transpose)
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
      beacon.unrotate(rotation).translate(position)
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

          # the first overlapping beacon, relative to this scanner's location/rotation:
          this_beacon = relative_locations[bspace.index(overlap.first)]
          debug { "  this beacon (relative):   #{this_beacon}" }

          # the other beacon's relative position in its scanner's zero rotation.
          # but we know it only matches when rotated to `orotation`, so rotate it:
          other_beacon = other.relative_locations[ospace.index(overlap.first)].rotate(orotation)
          debug { "  other (relative):         #{other_beacon}" }

          # now find the relative scanner position based on the difference,
          # still in this scanner's rotation:
          relative = this_beacon.sub(other_beacon)
          debug { "  relative pos: #{relative}" }
          # unrotate to get back to absolute positioning
          relative = relative.unrotate(rotation)
          debug { "  relative pos (absolute): #{relative}" }
          debug { "  position: #{position}" }

          # convert relative distance to absolute:
          pos = position.translate(relative)
          debug { "  pos (translated): #{pos}" }

          debug do
            abso = overlap.map { |o| beacons[bspace.index(o)] }
            "  overlapping (absolute): #{abso}"
          end
          debug do
            brels = overlap.map { |o| relative_locations[bspace.index(o)] }
            "  overlapping (in bspace): #{brels}"
          end
          debug do
            orels = overlap.map { |o| other.relative_locations[ospace.index(o)] }
            "  overlapping (in ospace): #{orels}"
          end

          # get the final combined rotation for the other scanner
          orotation = orotation.transpose * rotation
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

  n = scanners.length
  bar = progress_bar(title: "matching", total: (n * (n + 1) / 2)) unless debug?
  until to_match.empty?
    # see if we can match:
    matched = false
    scanners.select(&:located?).each do |scanner|
      to_match.each do |candidate|
        key = [scanner.num, candidate.num]

        next if compared.include?(key)

        bar.advance unless debug?
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
  bar.finish unless debug?

  # debug "scanners:\n#{scanners.map(&:position).pretty_inspect}"

  yield scanners
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

ex2beacons = <<EX
-892,524,684
-876,649,763
-838,591,734
-789,900,-551
-739,-1745,668
-706,-3180,-659
-697,-3072,-689
-689,845,-530
-687,-1600,576
-661,-816,-575
-654,-3158,-753
-635,-1737,486
-631,-672,1502
-624,-1620,1868
-620,-3212,371
-618,-824,-621
-612,-1695,1788
-601,-1648,-643
-584,868,-557
-537,-823,-458
-532,-1715,1894
-518,-1681,-600
-499,-1607,-770
-485,-357,347
-470,-3283,303
-456,-621,1527
-447,-329,318
-430,-3130,366
-413,-627,1469
-345,-311,381
-36,-1284,1171
-27,-1108,-65
7,-33,-71
12,-2351,-103
26,-1119,1091
346,-2985,342
366,-3059,397
377,-2827,367
390,-675,-793
396,-1931,-563
404,-588,-901
408,-1815,803
423,-701,434
432,-2009,850
443,580,662
455,729,728
456,-540,1869
459,-707,401
465,-695,1988
474,580,667
496,-1584,1900
497,-1838,-617
527,-524,1933
528,-643,409
534,-1912,768
544,-627,-890
553,345,-567
564,392,-477
568,-2007,-577
605,-1665,1952
612,-1593,1893
630,319,-379
686,-3108,-505
776,-3184,-501
846,-3110,-434
1135,-1161,1235
1243,-1093,1063
1660,-552,429
1693,-557,386
1735,-437,1738
1749,-1800,1813
1772,-405,1572
1776,-675,371
1779,-442,1789
1780,-1548,337
1786,-1538,337
1847,-1591,415
1889,-1729,1762
1994,-1805,1792
EX

part 1
debug!

with :overlaps
try manual, [[[0, 0], [0, 4], [4, 0]], [[1, 2], [3, 3], [4, 4]]]
with :part1, rotations: TWO_D_ROTATIONS, minimum: 3 do |scanners|
  scanners.flat_map(&:beacons).uniq.length
end
debug!
try ex1, 3
with :part1, rotations: THREE_D_ROTATIONS, minimum: 12 do |scanners|
  good = Input.new(ex2beacons).lines_of(:signed_numbers).to_set
  scanners.each_with_index do |s, i|
    next if s.beacons.to_set.subset?(good)

    bad = (s.beacons.to_set - good)
    debug { "scanner #{i} has #{bad.length} bad beacons" }
  end
  [scanners.map(&:position), scanners.flat_map(&:beacons).uniq.length]
end
try ex2, [[[0, 0, 0], [68, -1246, -43], [1105, -1205, 1229], [-92, -2380, -20], [-20, -1133, 1061]], 79]

no_debug!
with :part1, rotations: THREE_D_ROTATIONS, minimum: 12 do |scanners|
  scanners.flat_map(&:beacons).uniq.length
end
try puzzle_input

# part 2
# with :part2
# debug!
# try ex1, nil
# no_debug!
# try puzzle_input
