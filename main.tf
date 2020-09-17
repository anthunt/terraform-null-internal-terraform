variable disabled {
	description = "if true then module not work. default is false."
	type 		= bool
	default 	= false
}

variable apply {
	description = <<EOF
If this value is true, terraform apply for the sub module is executed, and if f
alse, terraform plan is executed.
EOF
	type 		= bool
	default 	= false
}

variable module_source {
	description	= <<EOF
The module_source is module directory path for internal terraform.
internal_terraform_module will be copy the source module in the workspace of in
ternal_terraform module when terraform apply.
EOF
	type 		= string
	validation {
		condition 		= length(var.module_source) > 0
		error_message 	= "The module_source must be exists in the root module directory."
	}
}

variable workspace {
	description = <<EOF
The workspace of directory name to run for internal terraform. default is .inte
rnal_workspace
EOF
	type		= string
	default 	= ".internal_workspace"
	validation {
		condition 		= length(var.workspace) > 0
		error_message 	= "The workspace is required."
	}
}

variable runtime {
	type 		= object({
		os 			= string
		variables 	= map(any)
		outputs		= list(string)
	})
	default		= {
		os			= "windows"
		variables 	= {}
		outputs		= []
	}
	validation {
		condition = var.runtime.os == "windows" || var.runtime.os == "linux"
		error_message = "The runtime.os value must be a valid, windows or linux."
	}
}

locals {

	root_path		= abspath(path.root)
	module_name 	= basename(var.module_source)
	scripts_path	= abspath("${path.module}/scripts")
	internal 		= {
		source 				= abspath(var.module_source)
		apply				= var.apply
		workspace 			= var.workspace
		module_path 		= abspath("${var.workspace}/${local.module_name}")
		windows_variables 	= var.disabled ? {} : (var.runtime.os == "windows" ? var.runtime.variables : {})
		linux_variables 	= var.disabled ? {} : (var.runtime.os == "linux"   ? var.runtime.variables : {})
		outputs				= join(" ", var.runtime.outputs)
	}

	outputs			= {
		for output in flatten([
			for key, val in var.runtime.variables: [
				for output in var.runtime.outputs: {
					key		= key
					module 	= "${local.internal.module_path}.${key}"
					output 	= output
				}
			]
		]): output.key => output
	}
}

resource "null_resource" "windows" {
  
	for_each = local.internal.windows_variables

	triggers = {
		internal = jsonencode(local.internal)
	}

	provisioner "local-exec" {
		command		= "${local.scripts_path}/run_terraform.cmd"
		environment = {
			SOURCE 		= replace(local.internal.source, "/", "\\")
			COMMAND		= local.internal.apply ? "apply" : "plan"
			ROOT_PATH 	= replace(local.root_path, "/", "\\")
			WORKSPACE 	= replace(local.internal.workspace, "/", "\\")
			MODULE_NAME = local.module_name
			MODULE_PATH = replace(local.internal.module_path, "/", "\\")
			COPYED_NAME	= each.key
			VARIABLES 	= jsonencode(each.value)
			OUTPUTS		= local.internal.outputs
		}
	}
}

data "local_file" "output_files" {
	for_each	= local.outputs
    filename 	= "${each.value.module}/${each.value.output}.json"
	depends_on = [
		null_resource.windows
	]
}

output variables {
	value = {
		disabled 		= var.disabled
		apply			= var.apply
		module_source 	= var.module_source		
		workspace		= var.workspace
		runtime			= var.runtime
	}
	description = <<EOF
These output variables are input variables provided to the internal_terraform m
odule.
EOF
}

output results {
	value = {
		for key, val in data.local_file.output_files: key => local.internal.apply ? try(jsondecode(val.content), {}) : {}
	}
	description = <<EOF
This is the map type. These output results are output results of sub modules ex
ecuted with internal_terraform. The key value of this map is a string value pro
vided as outputs in the runtime item among input variables.
EOF
}
