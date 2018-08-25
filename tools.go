// +build tools

package tools

// These imports ensure that "go mod tidy" will include tools
// needed for building in go.mod so that "go mod download" can
// prefetch them during bootstrapping.
import (
	_ "github.com/golang/lint/golint"
	_ "github.com/golang/mock/mockgen"
	_ "golang.org/x/tools/cmd/cover"
	_ "golang.org/x/tools/cmd/goimports"
	_ "golang.org/x/tools/cmd/goyacc"
	_ "honnef.co/go/tools/cmd/unused"
)
