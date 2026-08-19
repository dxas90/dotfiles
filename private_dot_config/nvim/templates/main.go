package {{_file_name_}}

// When I wrote this, only God and I understood what I was doing
// Now, God only knows
import (
	"bufio"
	"fmt"
	"os"
)

var (
	reader *bufio.Reader = bufio.NewReader(os.Stdin)
	writer *bufio.Writer = bufio.NewWriter(os.Stdout)
)

func printf(f string, a ...interface{}) { fmt.Fprintf(writer, f, a...) }
func scanf(f string, a ...interface{})  { fmt.Fscanf(reader, f, a...) }

func main() {
	defer writer.Flush()
	var cases int
	scanf("%d\n", &cases)
	for n := 1; n <= cases; n++ {
		printf("Case #%d: \n", n)
	}
}

// ex: ts=4 sw=4 et filetype=go

