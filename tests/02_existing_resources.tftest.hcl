run "setup_sample_existing_resources" {
   command = apply
   module {
     source = "./tests/setup/create-simulated-existing-resources"
   }
 }

run "unit_test" {
   command = plan
   module {
      source = "./examples/existing-resources"
   }
   variables {
      existing_vpc_id                 = run.setup_sample_existing_resources.existing_vpc_id
      existing_alb_subnets            = run.setup_sample_existing_resources.existing_alb_subnets
      existing_ecs_subnets            = run.setup_sample_existing_resources.existing_ecs_subnets
      existing_alb_security_groups    = run.setup_sample_existing_resources.existing_alb_security_groups
      existing_ecs_security_groups    = run.setup_sample_existing_resources.existing_ecs_security_groups
      existing_route_table_public     = run.setup_sample_existing_resources.existing_route_table_public
      existing_route_table_private    = run.setup_sample_existing_resources.existing_route_table_private
  }
 }

run "e2e_test" {
   command = apply
   module {
      source = "./examples/existing-resources"
   }
   variables {
      existing_vpc_id                 = run.setup_sample_existing_resources.existing_vpc_id
      existing_alb_subnets            = run.setup_sample_existing_resources.existing_alb_subnets
      existing_ecs_subnets            = run.setup_sample_existing_resources.existing_ecs_subnets
      existing_alb_security_groups    = run.setup_sample_existing_resources.existing_alb_security_groups
      existing_ecs_security_groups    = run.setup_sample_existing_resources.existing_ecs_security_groups
      existing_route_table_public     = run.setup_sample_existing_resources.existing_route_table_public
      existing_route_table_private    = run.setup_sample_existing_resources.existing_route_table_private
  }
 }
