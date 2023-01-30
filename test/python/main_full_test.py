#!/usr/bin/env python
import os

from cdktf import App, TerraformOutput, TerraformStack
from cdktf_cdktf_provider_local.file import File
from cdktf_cdktf_provider_local.provider import LocalProvider
from cdktf_cdktf_provider_random.provider import RandomProvider
from cdktf_cdktf_provider_random.string_resource import StringResource
from constructs import Construct


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, stack_id: str) -> None:
        super().__init__(scope, stack_id)

        # Initialize the providers.
        LocalProvider(scope=self, id="local")

        RandomProvider(scope=self, id="random")

        # Declare the resources.
        file_content = StringResource(scope=self, id="content", length=20)

        file_path = os.path.join(os.getcwd(), "foo.txt")
        file = File(scope=self, id="file", filename=file_path, content=file_content.result)

        # Declare the outputs.
        TerraformOutput(scope=self, id="file_name", description="The file name", value=file.filename)


app = App()
MyStack(app, "test")
app.synth()
