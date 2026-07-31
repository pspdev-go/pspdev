//go:build ignore

package main

import (
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
)

func main() {
	must(os.MkdirAll("assets", 0o755))
	writePNG("assets/ICON0.PNG", 144, 82, color.RGBA{R: 0x35, G: 0x79, B: 0xf6, A: 0xff})
	writePNG("assets/PIC1.PNG", 480, 272, color.RGBA{R: 0x18, G: 0x12, B: 0x21, A: 0xff})
}

func writePNG(path string, width, height int, fill color.RGBA) {
	file, err := os.Create(filepath.Clean(path))
	must(err)
	defer file.Close()

	image := image.NewRGBA(image.Rect(0, 0, width, height))
	for y := range height {
		for x := range width {
			image.SetRGBA(x, y, fill)
		}
	}
	must(png.Encode(file, image))
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
