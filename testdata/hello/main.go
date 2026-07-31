package main

import (
	"github.com/pspdev-go/pspsdk-go/psp/debugscreen"
	"github.com/pspdev-go/pspsdk-go/psp/kernel"
)

func main() {
	debugscreen.Init()
	debugscreen.PutString("Hello from Docker!")
	kernel.ExitGame()
}
