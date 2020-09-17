module internal_terraform {
    source  = "anthunt/internal-terraform/null"
    #version = "0.0.1"
  
    apply = true
    module_source = "./test"
    runtime = {
        os = "windows"
        variables = {
            Sample = {
                test = "AAAA"
                test1 = "BBBB"
            }
        }
        outputs = [
            "test"
        ]
    }
}

output internal_terraform_variables {
    value = module.internal_terraform.variables
}

output internal_terraform_results {
    value = module.internal_terraform.results
}
