Refer to the diagram in this repo to see current infrastructure.
This is documentation for debugging the existing infrastructure. 
The issue was that the bastion server was not able to connect to the private instances and our registered targets kept coming back unhealthy.

>> Solution: In our health check path instead of putting "/readme.html" we are supposed to put "/phpinfo.php" that way our targets can come back healthy. In our load balancer security group outbound rules there was port 110 POP3 being used, we have to take that off and leave our rules to just port 80 / source 0.0.0.0/0. In our Bastion security group we are ONLY supposed to have port 22 / source 0.0.0.0/0, NOT port 80 in addition. Targets are only supposed to be our webserver instances. For bastion to sucessfully access private instances we have to add our identity key via ssh client with [ ssh-add -k "YourPemFile" ] then use "ssh -A ec2-user@ThePublicIP" once logged in to access the private instance just use "ssh ec2-user@ThePrivateIP".     


Steps taken in debug process: Going to recreate from scratch to find solution

- VPC creation

- Internet gateway created + gateway attachment to VPC

- Creation of 2 public subnets (AZ's used: us-east-1a + us-east-1b) with enabled auto-assign public IPv4 address 

- Creation of 2 private subnets (same AZ's) 

- Creation of 2 more subnets for our database (same AZ's)

- Creation of NAT gateway and attached to second public subnet + elastic IP allocated

- Route tables: public + private + DB created 

- Public route added open cidr destination (0.0.0.0/0) with the target as the internet gateway

- Subnets added into public route table (2 public subnets)

- Private route added open cidr destination with the NAT gateway as the target

- Subnets added into private route table (2 private subnets)

- DB route table: subnets associated (2 DB subnets) NO ROUTES

- Going to create security groups now 

- First will be Bastion- port 22 / source open cidr 

- Second will be the security group used for the application load balancer- port 80 / source open cidr 

- Third will be for the webservers- port 22 / source bastion SG + port 80 / source application load balancer SG
 
- Fourth will be for our database- port 3306 / source webserver SG

- Now for launch configurations: 

- Launch config for webserver created with bootstrap script attached + using webserver SG

- Auto scaling group created for webserver using webserver launch config + 2 private subnets used

- Launch config for bastion created + using bastion SG

- Auto scaling group for bastion created using bastion launch config + 2 public subnets

- Creation of application load balancer using port 80 with 2 public subnets + load balancer SG

- New target group created - health check path /phpinfo.php + registered webserver instance as target >> target came back healthy

- Going to cross verify that bastion can do what is expected by logging into it and accessing private instances

- Verified bastion can log into private instances by using ssh client to add identity key and sucessfully logged into private instance from bastion

- Ran a ping test on both bastion and the private instance and both have sucessful connection to the internet

- More verification: took DNS of load balancer and pasted into my browser- wordpress index sucessfully loaded 

- Exit criteria has been met: bastion can sucessfully connect to private instances + targets registered healthy / infrastructure is now able to connect DB to wordpress.

