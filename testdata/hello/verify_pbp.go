//go:build ignore

package main

import (
	"encoding/binary"
	"fmt"
	"os"
)

func main() {
	data, err := os.ReadFile("build/pspgo/cmake/EBOOT.PBP")
	must(err)
	if len(data) < 40 || string(data[:4]) != "\x00PBP" {
		panic("invalid PBP header")
	}

	var offsets [8]uint32
	for i := range offsets {
		offsets[i] = binary.LittleEndian.Uint32(data[8+i*4:])
	}
	assertPresent("ICON0.PNG", offsets[1], offsets[2])
	assertPresent("PIC1.PNG", offsets[4], offsets[5])
	fmt.Println("PBP contains ICON0.PNG and PIC1.PNG")
}

func assertPresent(name string, start, end uint32) {
	if end <= start {
		panic(name + " is empty")
	}
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
