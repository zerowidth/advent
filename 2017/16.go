package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

func main() {
	input, err := ioutil.ReadFile("16.txt")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("---")
	// dance("s1", 5, 1)
	// dance("s2", 5, 1)
	// dance("s3", 5, 1)
	// dance("s4", 5, 1)
	// dance("s5", 5, 1)
	// dance("s0", 5, 1)
	// dance("s100", 5, 1)
	// dance("x3/4", 5, 1)
	// dance("x4/0", 5, 1)
	// dance("pa/b", 5, 1)
	// dance("pe/b", 5, 1)
	// dance("pb/e", 5, 1)
	// dance("s1,x3/4,pe/b", 5, 1)
	// dance("s1,x3/4,pe/b", 5, 2)
	// dance(strings.Trim(string(input), "\n"), 16, 1)
	dance(strings.Trim(string(input), "\n"), 16, 1000000000)
}

type danceMove struct {
	move byte
	a    int
	b    int
}

func indexof(needle byte, haystack []byte) int {
	for i := 0; i < len(haystack); i++ {
		if haystack[i] == needle {
			return i
		}
	}
	panic("not found")
}

func dance(input string, dancers, dances int) {
	moveStrings := strings.Split(input, ",")
	// fmt.Printf("%q\n", moveStrings)
	moves := []danceMove{}
	for _, move := range moveStrings {
		dm := danceMove{}
		dm.move = move[0]
		switch dm.move {
		case 's':
			i, err := strconv.Atoi(move[1:])
			if err != nil {
				log.Fatal(err)
			}
			dm.a = i
		case 'x':
			xs := strings.Split(move[1:], "/")
			a, err := strconv.Atoi(xs[0])
			if err != nil {
				log.Fatal(err)
			}
			b, err := strconv.Atoi(xs[1])
			if err != nil {
				log.Fatal(err)
			}
			dm.a = a
			dm.b = b
		case 'p':
			xs := strings.Split(move[1:], "/")
			dm.a = int(xs[0][0])
			dm.b = int(xs[1][0])
		}
		moves = append(moves, dm)
	}
	// fmt.Printf("%v\n", moves)

	partners := []byte("abcdefghijklmnop")[0:dancers]
	temp := make([]byte, dancers)
	seen := make(map[string]struct{})

	for dance := 0; dance < dances; dance++ {
		for _, move := range moves {
			switch move.move {
			case 's':
				offset := move.a % dancers
				if offset == 0 || offset == len(partners) {
					continue
				}
				for i := 0; i < dancers; i++ {
					temp[(i+offset)%dancers] = partners[i]
				}
				for i := 0; i < dancers; i++ {
					partners[i] = temp[i]
				}
			case 'x':
				partners[move.a], partners[move.b] = partners[move.b], partners[move.a]
			case 'p':
				a := indexof(byte(move.a), partners)
				b := indexof(byte(move.b), partners)
				partners[a], partners[b] = partners[b], partners[a]
			}
		}
		if _, ok := seen[string(partners)]; ok {
			remainder := dances % dance
			dance = dances - remainder
			fmt.Printf("loop at %d, %d remaining\n", dance, remainder)
			seen = make(map[string]struct{})
		} else {
			seen[string(partners)] = struct{}{}
		}
		if dance%100 == 0 {
			fmt.Printf("\r%d ", dance)
		}
	}
	fmt.Print("=> ")

	fmt.Println(string(partners))
}
