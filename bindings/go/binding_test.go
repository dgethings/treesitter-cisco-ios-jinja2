package tree_sitter_cisco_ios_jinja2_test

import (
	"testing"

	tree_sitter_cisco_ios_jinja2 "github.com/dgethings/tree-sitter-cisco-ios-jinja2/bindings/go"
	tree_sitter "github.com/tree-sitter/go-tree-sitter"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_cisco_ios_jinja2.Language())
	if language == nil {
		t.Errorf("Error loading Cisco IOS grammar")
	}
}
