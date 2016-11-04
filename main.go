package main

import (
	"fmt"
	"github.com/golang-collections/go-datastructures/slice"
	"os"
)

const VERSION = "0.1.0"

var phrases = map[int64]string{
	0:             "%s is not bytey at all.",
	10:            "%s is a wee bit bytey.",
	100:           "%s is a bit bytey.",
	1024:          "%s is somewhat bytey.", // kilobyte
	10240:         "%s is pretty bytey.",
	102400:        "%s is massively bytey.",
	1048576:       "%s is nearly mega-bytey.", // megabyte
	536870912:     "%s is pretty damn bytey.",
	1073741824:    "%s is nearly giga-bytey.", // gigabyte
	1099511627776: "%s is terribly bytey.",    // terabyte
}

func bytey(file string, keys slice.Int64Slice) (string, int64) {

	stats, err := os.Stat(file)
	if err != nil {
		return "%s does not exist", 0
	}

	out := phrases[0]
	bytes := stats.Size()
	for _, size := range keys {
		//fmt.Printf("Testing %d\n", size)
		if stats.Size() < size {
			return out, bytes
		}
		out = phrases[size]
	}
	return "Wow! %s is really bytey!", bytes
}

func main() {

	if len(os.Args) < 2 || os.Args[1] == "--help" {
		fmt.Println("bytiness [file]")
		os.Exit(0)
	}
	if os.Args[1] == "--version" {
		fmt.Printf("bytiness %s\n", VERSION)
		os.Exit(0)
	}

	// sort the keys here so we don't do it for
	// every file
	var keys slice.Int64Slice
	for k := range phrases {
		keys = append(keys, k)
	}
	keys.Sort()

	for _, file := range os.Args[1:] {
		phrase, size := bytey(file, keys)
		fmt.Printf(phrase+" (%d)", file, size)
		fmt.Println()
	}
}
