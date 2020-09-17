variable test {
    type = string
}

variable test1 {
    type = string
}

output test {
    value= {
        test = var.test
        test1 = var.test1
    }
}
