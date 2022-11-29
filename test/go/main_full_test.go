package main

import (
	localFile "github.com/cdktf/cdktf-provider-local-go/local/file"
	localProvider "github.com/cdktf/cdktf-provider-local-go/local/provider"
	randomProvider "github.com/cdktf/cdktf-provider-random-go/random/provider"
	"github.com/cdktf/cdktf-provider-random-go/random/stringresource"
	"github.com/hashicorp/terraform-cdk-go/cdktf"
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
			Length: jsii.Float64(20),
		},
	)

	file := localFile.NewFile(
		stack,
		jsii.String("file"),
		&localFile.FileConfig{
			Content:  fileContent.Content(),
			Filename: jsii.String("foo.txt"),
		},
	)

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

	NewMyStack(app, "dev")

	app.Synth()
}
