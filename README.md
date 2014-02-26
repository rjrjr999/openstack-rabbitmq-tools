OpenStack RabbitMQ Tools
========================
This repository contains a tool to publish messages onto a rabbitmq queue.  
The tool was written to simulate Nova VM instance creation and deletion 
messages for consumption by OpenStack Designate.

Usage
=====
1. Place the amqppublisher.py and createsimscript.sh scripts into the same 
directory.
2. Edit the createsimscript.sh script and modify the variables for the local 
environment.
3. Run the createsimscript.sh script:

	./createsimscript.sh <user> <password> <tenant> <hostname> <ipaddress>

   The script will create a script called simnova_<hostname>.sh.  That script
   will be used to simulate Nova VM instance creation and deletion.

4. Run the simnova_<hostname>.sh script to simulate Nova VM instance creation:

	./simnova_<hostname>.sh create

5. run the simnova_<hostname>.sh script to simulate Nova VM instance deletion:

	./simnova_<hostname>.sh delete

Assumptions
===========
The system this tool will be run on has:
* Keystone client
* Python 2.6 or higher

Additional Notes
================
This tool was inspired by the rabbitmq-utilites found here:

	https://github.com/kumarcv/rabbitmq-utilities
