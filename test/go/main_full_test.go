package main

import (
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
	localFile "github.com/cdktf/cdktf-provider-local-go/local/v4/file"
	localProvider "github.com/cdktf/cdktf-provider-local-go/local/v4/provider"
	randomProvider "github.com/cdktf/cdktf-provider-random-go/random/v4/provider"
	"github.com/cdktf/cdktf-provider-random-go/random/v4/stringresource"
	"github.com/hashicorp/terraform-cdk-go/cdktf"
	"os"
	"path/filepath"
)

func NewMyStack(scope constructs.Construct, id string) cdktf.TerraformStack {
	// Create the stack.
	stack := cdktf.NewTerraformStack(scope, &id)

	// Initialize the providers.
	localProvider.NewLocalProvider(
		stack,
		jsii.String("local"),
		&localProvider.LocalProviderConfig{},
	)

	randomProvider.NewRandomProvider(
		stack,
		jsii.String("random"),
		&randomProvider.RandomProviderConfig{},
	)

	// Declare the resources.
	fileContent := stringresource.NewStringResource(
		stack,
		jsii.String("content"),
		&stringresource.StringResourceConfig{
			Length: jsii.Number(20),
		},
	)

	currentDir, _ := os.Getwd()
	filePath := filepath.Join(currentDir, "foo.txt")
	file := localFile.NewFile(
		stack,
		jsii.String("file"),
		&localFile.FileConfig{
			Filename: jsii.String(filePath),
			Content:  fileContent.Result(),
		},
	)

	// Declare the outputs.
	cdktf.NewTerraformOutput(
		stack,
		jsii.String("file_name"),
		&cdktf.TerraformOutputConfig{
			Description: jsii.String("The file name"),
			Value:       file.Filename(),
		},
	)

	return stack
}

func main() {
	app := cdktf.NewApp(nil)
	NewMyStack(app, "test")
	app.Synth()
}
