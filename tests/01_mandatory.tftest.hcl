run "unit_test" {
  command = plan
  module {
    source = "./examples/basic"
  }
}

run "e2e_test" {
  command = apply
  module {
    source = "./examples/basic"
  }
}
