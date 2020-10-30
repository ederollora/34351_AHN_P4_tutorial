/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;

/*TODO: Find the correct number in IPv4's protocol for UDP*/
/*const bit<8> PROTO_UDP = FIND_VALUE;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

/*TODO: Search for the UDP header structure, define it here and
add necessary fields. Remember that UDP header is 8 bytes in total.
It needs to have 4 fields.
Hint: https://en.wikipedia.org/wiki/User_Datagram_Protocol*/
/*TODO - IMPORTANT: To prevent having issues with the rules, you should
choose "dstPort" and "srcPort" for UDP fields. The rest of the fields don't
that much matter*/



/*TODO: Add a header for your telemetry data, the structure is the following:
    - header name: up to you
    - necessary fields:
      - size: 3, name: switch_num.
        - Will hold switch number
      - size: 1, name: in_out
        - in_out = 0 when you process the ingress port number.
        - in_out = 1 when you process the egress port number.
      - size: 9, name: port_num
      - size: 3, name: _pad
          - This header is never used, it used so that header size is 16 bits.
          - You will equal it to 0 later on.
*/

struct metadata {
    /* empty */
}

/*Header instantiation*/
struct headers {
    ethernet_t       ethernet;
    ipv4_t           ipv4;
    /*TODO: Declare the UDP header */
    /*TODO: declare your telemetry header two times:
        - One is used for processing ingress port information
        - The other header is used for processing egress port information

        Use the same header type for both but a different name for each,
        of course.*/
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
        /*TODO: Remove "transition accept" and write a transition that will
        parse UDP header if the value in protocol is PROTO_UDP. PROTO_UDP
        has been defined at the very beginning of the script. On default,
        transition to accept.*/
    }

    /*TODO: Parse UDP header and transition to accept*/

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        if (hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
        }
    }

}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    /*TODO-README: This section is necessary because you need to know the
    output port to which the packet will be outputed. This value can only be
    read in the egress because you decide to establish it in the ingress. There
    are other ways in which you can save the output port number but we will
    assume in this case that you HAVE TO take it from standard_metadata. Therefore,
    you need to find the correct field of standard_metadata for that.*/

    action record_ports(bit<3> switch_num) {

        /*TODO. You have declared two headers for the telemetry
        header you created. Set them both valid.*/

        /*TODO. We work with the first telemetry header. Assign switch_num
        field from the telemetry header to the value you get as parameter of
        this action. Assigning 0 or 1 to in_out (depends if this is ingress
        or egress port telemetry header, in_out=0 for in port, in_out=2 for out).

        Then assign port_num to either ingress port or egress port. See
        standard_metadata fields to see which field you have to pick.
        Finally, assign _pad to 0.
        Hint for checking standard_metadata:
         - https://github.com/p4lang/behavioral-model/blob/master/docs/simple_switch.md
           - See "standard metadata" section.
           - In the past standard_metadata was called intrinsic_metadata so don't
           get confused for the naming.

        /*TODO: If you assigned the field for ingress port to in the previous "TODO"
        , then now use the second telemetry header and assign values for egress
        port related field. That is, in_out equal to 1, port_num qual to egress
        port, etc. Keep the same switch num as before. If you used egress port
        related fields in the previous "TODO" then do ingress now.*/

        /*TODO: Modify ipv4 header and udp header length. Check the name for the
        field that holds length information as it is different in both headers.
        Incremenet by N bytes each of those two headers. The number of bytes
        you have to add up to the field is up to the bytes you add each time
        you include telemetry headers. Check the bits of the telemetry header
        you just created and multiply by two as you add two of them. Remember
        you have to add a number in bytes, not bits. */
    }

    table route_v {
        key = {
            /*TODO: add one match for UDP source port with type exact:
            udp_source_port :exact; */
            /*TODO: add one match for UDP destination port with type exact:
            udp_destination_port :exact; */
        }
        actions = {
            record_ports;
            NoAction;
        }
        size = 10;
        default_action = NoAction;
    }


    apply {
        /*TODO: Check if UDP is valid*/
            /*TODO: apply the table you see declared above when UDP is valid*/
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        /*TODO: Deparse UDP header */
        /*TODO: Deparse the two telemetry headers you declared at the beginning
        of the P4 program. Remember that the telemetry header with the ingress
        port information has to be deparsed BEFORE the telemetry header used
        for the egress port. This is becaise the destination will expect
        telemetry headers this EXACT order.*/
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
