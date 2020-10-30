# Implementing Route Validation

## Introduction

As you have seen in one of our demos, you can monitor the network with P4
switches. You cannot monitor all the features you can imagine, but there are a
few parameters that we can gather.

We have built this exercise from the first exercise that you have completed,
the basic exercise. The P4 code that you need to modify uses the solution from
the basic exercise but needs some modifications.

The goal in this exercise is that you can monitor the path that a packet
traverses. In short, you will need to modify the P4 code so that each switch
adds an additional information to the original packet, like the ingress port,
egress port and the switch id (i.e. switch number). You will have a better
explanation, step by step soon.

Adding additional information to the packet will show you how you can
implement a use cases, similar to the In-Band Network Telemetry (INT) that you
have seen in our lab. In this way, you can add information to the packet as it
traverses each switch until it arrives to the destination. In this case we
don't remove the information before sending the "original" packet to the
destination as it would require more work. Therefore, the packet, with the
telemetry data, will arrive to the destination.

The topology for this exercise is the same as the on used in the basic
exercise. It is a single pod of a fat-tree topology and henceforth referred
to as pod-topo: ![pod-topo](./pod-topo/pod-topo.png)

Similar to the basic exercise, the P4 program will be written for the V1Model
architecture implemented on P4.org's bmv2 software switch.


## Step 1: Run the (incomplete) starter code

The directory with this README also contains a `route_validator` program based on
`basic.p4`. Your job will be to extend this skeleton program to properly
addd telemetry headers and forward IPv4 packets.

Before that, let's compile the incomplete `route_validator.p4` and bring
up a switch in Mininet to test its behavior.

1. In your shell, run:
   ```bash
   make run
   ```
   This will:
   * compile `route_validator.p4`, and
   * start the pod-topo in Mininet and configure all switches with
   the appropriate P4 program + table entries, and
   * configure all hosts with the commands listed in
   [pod-topo/topology.json](./pod-topo/topology.json)

2. You should now see a Mininet command prompt. Try to ping between
   hosts in the topology:
   ```bash
   mininet> xterm h1 h2
   ```
3. At the h2 xterm you have to run this command:
  ```bash
  root@p4> python receive.py
  ```

4. At the h1 xterm you have to run the following command. The first script
parameter is the destination IP of the UDP packet that send.py will send. We
are sending a packet from h1 to h2, so h2's IP is 10.0.2.2 . The source port
for the UDP is 10000 and the destination port will be 20000:
  ```bash
  root@p4> python send.py 10.0.2.2 10000 20000
  ```

5. If you look into h2's xterm window you should see this text:
  ```bash
  Listening for UDP packets on eth0 interface:
  UDP packet captured but no telemetry information in it.
  ```
This means that you have to modify the P4 program to add the telemetry headers.

6. Type `exit` to leave each xterm and the Mininet command line.
   Then, to stop mininet:
   ```bash
   make stop
   ```
   And to delete all pcaps, build files, and logs:
   ```bash
   make clean
   ```


### A note about the table rules

The table rules are placed in `pod-topo` folder. Go from `s1-runtime.json`
until `s4-runtime.json`. When you modify the P4 program and add the `route_v`
table, then you have to remove the rules on `pod-topo` folder and copy the ones
from `new_table_rules` folder. These new json files (that have the same name)
contain a new rule for each switch. This new rule will match packet with UDP
source port for 10000 and UDP destination port for 20000. When the packet
matches, each rule will give the switch number as an action parameter.
This table decides when a packet will have telemetry headers appended. In this
case, packets with UDP header and source port = 10000 and destination port = 20000
will hold telemetry headers.

**Informational:** As with P4 tutorial exercises, the script uses P4Runtime to install
the control plane rules.

The content of files `sX-runtime.json` refer to specific names of tables, keys, and
actions, as defined in the P4Info file produced by the compiler (look for the
file `build/route_validator.p4.p4info.txt` after executing `make run`).
If you proceed with custom changes to our started P4 code like adding or renaming
tables, keys, or actions will need to be reflected in these `sX-runtime.json` files.

## Step 2: Implement route validation

The `route_validator.p4` file contains a skeleton P4 program with key pieces of
logic replaced by `TODO` comments. Your implementation should follow
the structure given in this file---replace each `TODO` with logic
implementing the missing piece.

A complete `route_validator.p4` will, as a summary, have the following
TODO tasks:

1. **TODO:** Add the UDP header structure with its fields.
2. **TODO:** Add the telemetry header, see the P4 file to follow instructions.
3. **TODO:** Declare the UDP header and two telemetry headers you just created.
4. At the Ingress, we have left the `basic.p4` code to route IP packets. You
don't have to modify this code.
5. **TODO:** At the Egress, we have created a table for which you have to
create the keys, and also fill up the `record_ports` action. All instructions
are described in the P4 file.
6. **TODO:** Finally, fill up the deparser with the appropriate headers. There
are specific instructions for the order in which the headers have to be
deparsed. Please read carefully the instruction on the P4 file.


## Step 3: Run your completed solution

**Before you run the code once you have completed all modifications,
remember to replace json rules at `pod-topo` folder with copying the rules
from folder `new_table_rules` folder**

Follow the instructions from Step 1. This time, you should be able to
successfully ping between any two hosts in the topology.

1. In your shell, run:
   ```bash
   make run
   ```

2. You should now see a Mininet command prompt. Try to ping between
   hosts in the topology:
   ```bash
   mininet> xterm h1 h2 h3
   ```
3. At the h2 xterm you have to run this command:
  ```bash
  root@p4> python receive.py
  ```

3. Do the same for the h3 host:
  ```bash
  root@p4> python receive.py
  ```

4. At the h1 xterm you have to run the following command first sending a packet
to h2 and then run the same sending a packet to h3. Results will be different
the path from h1 to h2 is different from the path of the packet from h1 to h3.
  ```bash
  root@p4> python send.py 10.0.2.2 10000 20000
  ```

5. If you look into h2's xterm window you should see this text.. If your program
works properly, you will see this output:
  ```bash
  Listening for UDP packets on eth0 interface:
  Captured UDP packet with telemetry.
  inPort(1) -> Switch(1) -> outPort(2)
  ```
This text means that the received detected telemetry data and shows that the
packet entered Switch 1 via port 1 and then was sent out of port 2. You can
confirm this path by checking out the `pod-topo.png` file at `pod-topo` folder.

4. Go back to h1 xterm you have to run the following command to send a packet
to h3.
  ```bash
  root@p4> python send.py 10.0.3.3 10000 20000
  ```

5. If you look into h3's xterm window you should see this text. If your program
works properly, you will see this output:
  ```bash
  Listening for UDP packets on eth0 interface:
  Captured UDP packet with telemetry.
  inPort(4) -> Switch(2) -> outPort(1)
  inPort(1) -> Switch(3) -> outPort(2)
  inPort(1) -> Switch(1) -> outPort(3)
  ```
This text means that h3 received a UDP packet with telemetry data and shows
that the packet entered Switch 1 via port 1 and then was sent out of port 3
(towards switch 3). After that Switch 3 got a packet via port 1 and then sent
it via port 2 (towards switch 2). Finally, at switch 2, the packet was received
via port 4 and then it was sent via port 1 (towards h3). You can confirm this
path by checking out the `pod-topo.png` file at `pod-topo` folder.


#### Cleaning up Mininet

In the latter two cases above, `make run` may leave a Mininet instance
running in the background. Use the following command to clean up
these instances:

```bash
make stop
```
