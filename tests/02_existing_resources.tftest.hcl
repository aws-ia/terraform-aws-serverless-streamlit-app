run "unit_test" {
   command = plan
   module {
      source = "./examples/existing-resources"
   }
}

run "e2e_test" {
   command = apply
   module {
      source = "./examples/existing-resources"
   }
}
