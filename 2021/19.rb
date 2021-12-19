require_relative "../toolkit"

TWO_D_ROTATIONS = [
  # there were no rotations in the 2d example
  Matrix[[1, 0], [0, 1]], # x y
  # Matrix[[1, 0], [0, -1]], # x -y
  # Matrix[[0, 1], [1, 0]], # y x
  # Matrix[[0, 1], [-1, 0]], # y -x
  # Matrix[[-1, 0], [0, 1]], # -x y
  # Matrix[[-1, 0], [0, -1]], # -x -y
  # Matrix[[0, -1], [1, 0]], # -y x
  # Matrix[[0, -1], [-1, 0]], # -y -x
]

THREE_D_ROTATIONS = [
  # z = z
  Matrix[[1, 0, 0], [0, 1, 0], [0, 0, 1]], # x = x, y = y
  Matrix[[0, 1, 0], [0, -1, 0], [0, 0, 1]], # x = y, y = -x
  Matrix[[-1, 0, 0], [0, 1, 0], [0, 0, 1]], # x = -x, y = -y
  Matrix[[0, -1, 0], [1, 0, 0], [0, 0, 1]], # x = -y, y = x

  # z = -z
  Matrix[[1, 0, 0], [0, 1, 0], [0, 0, -1]], # x = x, y = y
  Matrix[[0, 1, 0], [0, -1, 0], [0, 0, -1]], # x = y, y = -x
  Matrix[[-1, 0, 0], [0, 1, 0], [0, 0, -1]], # x = -x, y = -y
  Matrix[[0, -1, 0], [1, 0, 0], [0, 0, -1]], # x = -y, y = x

  # z = x
  Matrix[[0, 0, -1], [0, 1, 0], [1, 0, 0]], # x = -z, y = y
  Matrix[[0, 1, 0], [0, 0, 1], [1, 0, 0]], # x = y, y = z
  Matrix[[0, 0, 1], [0, -1, 0], [1, 0, 0]], # x = z, y = -y
  Matrix[[0, -1, 0], [0, 0, -1], [1, 0, 0]], # x = -y, y = -z

  # z = -x
  Matrix[[0, 0, -1], [0, 1, 0], [-1, 0, 0]], # x = -z, y = y
  Matrix[[0, 1, 0], [0, 0, 1], [-1, 0, 0]], # x = y, y = z
  Matrix[[0, 0, 1], [0, -1, 0], [-1, 0, 0]], # x = z, y = -y
  Matrix[[0, -1, 0], [0, 0, -1], [-1, 0, 0]], # x = -y, y = -z

  # z = y
  Matrix[[1, 0, 0], [0, 0, -1], [0, 1, 0]], # x = x, y = -z
  Matrix[[0, 0, -1], [-1, 0, 0], [0, 1, 0]], # x = -z, y = -x
  Matrix[[-1, 0, 0], [0, 0, 1], [0, 1, 0]], # x = -x, y = z
  Matrix[[0, 0, 1], [-1, 0, 0], [0, 1, 0]], # x = z, y = -x 

  # z = -y
  Matrix[[1, 0, 0], [0, 0, -1], [0, -1, 0]], # x = x, y = -z
  Matrix[[0, 0, -1], [-1, 0, 0], [0, -1, 0]], # x = -z, y = -x
  Matrix[[-1, 0, 0], [0, 0, 1], [0, -1, 0]], # x = -x, y = z
  Matrix[[0, 0, 1], [-1, 0, 0], [0, -1, 0]], # x = z, y = -x 
]

class Array
  def rotate(rotation)
    (rotation * Matrix.column_vector(self)).column(0).to_a
  end
end

class Beacon
  attr_reader :pos, :relative

  def initialize(pos, beacons)
    @pos = pos
    @relative = []
    beacons.each do |beacon|
      @relative << pos.zip(beacon).map { |p, b| b - p }
    end
    @relative = @relative.to_set
  end

  def rotations
    @rotations ||= ROTATIONS.map do |rotation|
      rotated = relative.map { |o| o.rotate(rotation) }
      [rotation, rotated.to_set]
    end
  end

  def to_s
    "<B #{pos} relative: #{relative}>"
  end

  alias inspect to_s
end

class Scanner
  attr_reader :beacons, :spaces, :position, :rotation

  def initialize(beacons, rotations:)
    @beacons = beacons
    @spaces = Hash.of_array
    rotations.each do |rotation|
      rotated = beacons.map { |b| b.rotate(rotation) }
      rotated.each do |beacon|
        @spaces[rotation] << rotated.map { |other| beacon.zip(other).map { |b, o| o - b } }
      end
    end
  end

  def positioned_beacons
    raise "can't, no location" unless located?

    beacons.map do |beacon|
      position.zip(beacon.rotate(rotation)).map { |p, b| p + b }
    end
  end

  def located?
    !!@position
  end

  def locate(position, rotation)
    @position = position
    @rotation = rotation
  end

  def overlap?(other, minimum:)
    # find first scanner which has an overlapping beacon space with another

    # assume this one is fixed, the other can rotate to match
    spaces.values.first.each do |space|
      debug "comparing #{space}"
      other.spaces.each do |orotation, ospaces|
        debug "  at rotation #{orotation.to_a}"
        ospaces.each do |ospace|
          overlap = space & ospace
          debug "  #{ospace}: overlap #{overlap}"
          if overlap.length >= minimum
            # locate the other scanner relative to this one:
            # S1 -> B -> S2
            # debug "overlap: #{overlap}"
            this_beacon = beacons[space.index(overlap.first)]
            # debug "this_beacon: #{this_beacon}"
            other_beacon = other.beacons[ospace.index(overlap.first)]
            # debug "other_beacon: #{other_beacon}"
            pos = this_beacon.zip(other_beacon).map { |t, o| t - o }
            # debug "pos: #{pos}"
            return pos, orotation
          end
        end
      end
    end
    nil
  end

  def to_s
    "<S #{beacons} pos: #{position || "?"} rot: #{rotation || "?"}>"
  end
end


def part1(input, rotations:)
  scanners = input.sections.with_progress(title: "loading beacons").map do |section|
    beacons = section.lines.drop(1).map(&:signed_numbers)
    Scanner.new(beacons, rotations: rotations)
  end
  scanners.first.locate([0, 0], rotations.first)

  a = scanners.first
  b = scanners.last

  if (pos, rot = a.overlap?(b, minimum: 3))
    b.locate(pos, rot)
  end

  scanners.flat_map(&:positioned_beacons).uniq.size
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
with :part1, rotations: TWO_D_ROTATIONS
debug!
try ex1, 3
with :part1, rotations: THREE_D_ROTATIONS
# try ex2, 79
no_debug!
try puzzle_input

part 2
with :part2
debug!
try ex1, nil
no_debug!
try puzzle_input
