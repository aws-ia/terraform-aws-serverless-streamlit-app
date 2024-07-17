output "existing_vpc_id" {
  value = aws_vpc.sample_existing_vpc.id
}
output "existing_alb_subnets" {
  value = [aws_subnet.sample_existing_public_subnet1.id, aws_subnet.sample_existing_public_subnet2.id]
}
output "existing_ecs_subnets" {
  value = [aws_subnet.sample_existing_private_subnet1.id, aws_subnet.sample_existing_private_subnet2.id]
}
output "existing_alb_security_groups" {
  value = [aws_security_group.sample_existing_lb_sg.id]
}
output "existing_ecs_security_groups" {
  value = [aws_security_group.sample_existing_ecs_sg.id]
}
output "existing_route_table_public" {
    value = [aws_route_table.sample_existing_route_table_public.id]
}
output "existing_route_table_private" {
    value = [aws_route_table.sample_existing_route_table_private.id]
}
