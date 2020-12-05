require_relative "../toolkit"

ex1 = <<-EX
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
EX

INVALID = <<-EX
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
EX

VALID = <<-EX
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
EX

PARTS = <<PARTS
byr (Birth Year)
iyr (Issue Year)
eyr (Expiration Year)
hgt (Height)
hcl (Hair Color)
ecl (Eye Color)
pid (Passport ID)
cid (Country ID)
PARTS

FIELDS = PARTS.each_line.map(&:split).map(&:first) - ["cid"]

def part1(input)
  input.split("\n\n").select do |passport|
    has = passport.scan(/(\w+):\S+/).map(&:first)
    missing = FIELDS - has
    missing.empty?
  end.count
end

VALIDATIONS = {
  "byr" => ->(v) { (1920..2002).cover?(v.to_i) },
  "iyr" => ->(v) { (2010..2020).cover?(v.to_i) },
  "eyr" => ->(v) { (2020..2030).cover?(v.to_i) },
  "hgt" => ->(v) do
    v =~ /(\d+)(in|cm)/ &&
      (($2 == "in" && (59..76).cover?($1.to_i)) ||
       ($2 == "cm" && (150..193).cover?($1.to_i)))
  end,
  "hcl" => ->(v) { v =~ /^#[0-9a-f]{6}$/ },
  "ecl" => ->(v) { v =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/ },
  "pid" => ->(v) { v =~ /^[0-9]{9}$/ },
  "cid" => ->(v) { true },
}

def part2(input)
  input.split("\n\n").select do |passport|
    parsed = passport.scan(/(\w+):(\S+)/)
    (FIELDS - parsed.map(&:first)).empty? && parsed.all? { |field, value| VALIDATIONS[field][value] }
  end.count
end

part 1
with :part1
try ex1, expect: 2
try puzzle_input

part 2
with :part2
try INVALID, 0
try VALID, 4
try puzzle_input
