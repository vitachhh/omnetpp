package neznamvise.simulations;

import inet.linklayer.contract.IEthernetInterface;
import inet.linklayer.contract.ILoopbackInterface;
import inet.linklayer.contract.ITunnelInterface;
import inet.linklayer.contract.IVirtualInterface;
import inet.linklayer.contract.IWirelessInterface;
import inet.linklayer.ethernet.contract.IEthernetLayer;
import inet.linklayer.ieee8021r.IIeee8021rLayer;
import inet.linklayer.ieee8022.IIeee8022Llc;
import inet.networklayer.contract.INetworkLayer;
import inet.node.base.GamingApp;
import inet.node.base.NodeBase;
import inet.node.contract.IEthernetNetworkNode;
import inet.node.inet.StandardHost;
import inet.applications.contract.IApp;
import inet.protocolelement.contract.IProtocolLayer;
import inet.transportlayer.contract.ISctp;
import inet.transportlayer.contract.ITcp;
import inet.transportlayer.contract.IUdp;
import inet.linklayer.ieee8021q.IIeee8021qLayer;
import inet.common.packet.recorder.PcapRecorder;

module konzola extends NodeBase like IEthernetNetworkNode
{
    parameters:
        int numApps = default(0);
        bool hasUdp = default(firstAvailableOrEmpty("Udp") != "");
        bool hasTcp = default(firstAvailableOrEmpty("Tcp", "TcpLwip", "TcpNsc") != "");
        bool hasSctp = default(false);
        *.forwarding = this.forwarding;
        *.multicastForwarding = this.multicastForwarding;
        bool recordPcap = default(false);
        int numPcapRecorders = default(recordPcap ? 1 : 0);
        int numLoInterfaces = default(1);
        int numWlanInterfaces = default(1);
        int numEthInterfaces = default(1);
        int numTunInterfaces = default(0);
        int numVirtInterfaces = default(0);
        string fcsMode @enum("declared","computed") = default("declared");
        pcapRecorder[*].pcapFile = default("results/" + expand("${configname}-") + fullPath() + ".pcap");
        mobility.typename = default(numWlanInterfaces > 0 ? "StationaryMobility" : "");
        *.interfaceTableModule = default(absPath(".interfaceTable"));
        *.fcsMode = this.fcsMode;
        wlan[*].radio.antenna.mobilityModule = default("^.^.^.mobility");
        ethernet.registerProtocol = default(true);

        double cpuFrequency @unit("GHz") = default(1.02 GHz);
        int cpuCores = default(4);
        double gpuFrequency @unit("GHz") = default(0.92 GHz);
        double ramCapacity @unit("GB") = default(4 GB);
        double storageCapacity @unit("GB") = default(32 GB);


        double batteryCapacity @unit("mAh") = default(4310 mAh);
        double batteryChargingSpeed @unit("mAh/s") = default(1000 mAh/s);
        int batteryChargeCycles = default(800);
        double batteryHealth = default(0.95);
        bool batteryOverchargeProtection = default(true);
        double autoShutdownTimeout @unit("s") = default(1800s);



        @display("bgb=2406.096,1843.968");
    gates:
        input radioIn[numWlanInterfaces] @directIn;
        inout ethg[numEthInterfaces] @labels(EtherFrame-conn) @allowUnconnected;
    submodules:
        at: QSS {
            @display("p=663,133;b=718,11");
        }
        app[numApps]: <> like IApp {
            @display("p=570,44");
        }
        udp: <paramName> like IUdp {
            @display("p=424,227");
        }
        tcp: <paramName> like ITcp {
            @display("p=609,227");
        }
        sctp: <paramName> like ISctp {
            @display("p=831,227");
        }
        tn: QSS {
            @display("p=663,292;b=718,11");
        }
        nl: QSS {
            @display("p=663,450;b=718,11");
        }
        ipv4: <paramName> like INetworkLayer if hasIpv4 {
            @display("p=430,376");
        }
        ipv6: <paramName> like INetworkLayer if hasIpv6 {
            @display("p=710,351");
        }
        generic: <paramName> like INetworkLayer if hasGn {
            @display("p=864,376");
        }
        cb: QSS {
            @display("p=663,557;b=718,11");
        }
        llc: <paramName> like IIeee8022Llc if typename != "" {
            @display("p=506,521");
        }
        cb: QSS {
            @display("p=663,584;b=718,11");
        }
        bridging: <default("")> like IProtocolLayer if typename != "" {
            @display("p=624,652");
        }
        bl: QSS {
            @display("p=663,717;b=718,11");
        }
        li: QSS {
            @display("p=663,847;b=718,11");
        }
        ethernet: <default(sizeof(ethg) > 0 ? "EthernetEncapsulation" : "")> like IEthernetLayer if typename != "" {
            @display("p=376,776");
        }
        ieee8021q: <default("")> like IIeee8021qLayer if typename != "" {
            @display("p=560,776");
        }
        ieee8021r: <default("")> like IIeee8021rLayer if typename != "" {
            @display("p=839,776");
        }
        wlan[numWlanInterfaces]: <default("Ieee80211Interface")> like IWirelessInterface {
            @display("p=349,972");
        }
        eth[sizeof(ethg)]: <default("EthernetInterface")> like IEthernetInterface {
            @display("p=878,972");
        }
        tun[numTunInterfaces]: <default("TunInterface")> like ITunnelInterface {
            @display("p=1061,962");
        }
        virt[numVirtInterfaces]: <default("VirtualInterface")> like IVirtualInterface {
            @display("p=1147,900");
        }
        lo[numLoInterfaces]: <default("LoopbackInterface")> like ILoopbackInterface {
            @display("p=671,972");
        }
        pcapRecorder[numPcapRecorders]: PcapRecorder {
            @display("p=125,246;is=s");
        }

    connections allowunconnected:
        for i=0..numApps-1 {
            app[i].socketOut --> at.in++;
            app[i].socketIn <-- at.out++;
        }
        at.out++ --> udp.appIn if hasUdp;
        at.in++ <-- udp.appOut if hasUdp;

        at.out++ --> tcp.appIn if hasTcp;
        at.in++ <-- tcp.appOut if hasTcp;

        at.out++ --> sctp.appIn if hasSctp;
        at.in++ <-- sctp.appOut if hasSctp;

        at.out++ --> tn.in++;
        at.in++ <-- tn.out++;

        ipv4.ifIn <-- nl.out++ if hasIpv4;
        ipv4.ifOut --> nl.in++ if hasIpv4;

        ipv6.ifIn <-- nl.out++ if hasIpv6;
        ipv6.ifOut --> nl.in++ if hasIpv6;

        generic.ifIn <-- nl.out++ if exists(generic);
        generic.ifOut --> nl.in++ if exists(generic);

        cb.out++ --> nl.in++;
        cb.in++ <-- nl.out++;

        llc.upperLayerOut --> nl.in++ if exists(llc);
        llc.upperLayerIn <-- nl.out++ if exists(llc);

        llc.lowerLayerOut --> cb.in++ if exists(llc);
        llc.lowerLayerIn <-- cb.out++ if exists(llc);

        cb.out++ --> bridging.upperLayerIn if exists(bridging);
        bridging.upperLayerOut --> cb.in++ if exists(bridging);

        bridging.lowerLayerOut --> bl.in++ if exists(bridging);
        bl.out++ --> bridging.lowerLayerIn if exists(bridging);

        cb.out++ --> bl.in++ if !exists(bridging);
        bl.out++ --> cb.in++ if !exists(bridging);

        bl.out++ --> li.in++;
        li.out++ --> bl.in++;

        bl.out++ --> ieee8021q.upperLayerIn if exists(ieee8021q);
        ieee8021q.upperLayerOut --> bl.in++ if exists(ieee8021q);

        bl.out++ --> ieee8021r.upperLayerIn if exists(ieee8021r);
        ieee8021r.upperLayerOut --> bl.in++ if exists(ieee8021r);

        bl.out++ --> ethernet.upperLayerIn if exists(ethernet);
        ethernet.upperLayerOut --> bl.in++ if exists(ethernet);

        ieee8021q.lowerLayerOut --> li.in++ if exists(ieee8021q);
        li.out++ --> ieee8021q.lowerLayerIn if exists(ieee8021q);

        ieee8021r.lowerLayerOut --> li.in++ if exists(ieee8021r);
        li.out++ --> ieee8021r.lowerLayerIn if exists(ieee8021r);

        ethernet.lowerLayerOut --> li.in++ if exists(ethernet);
        li.out++ --> ethernet.lowerLayerIn if exists(ethernet);

        tn.out++ --> nl.in++;
        tn.in++ <-- nl.out++;

        for i=0..sizeof(radioIn)-1 {
            radioIn[i] --> { @display("m=s"); } --> wlan[i].radioIn;
        }

        for i=0..sizeof(ethg)-1 {
            ethg[i] <--> { @display("m=s"); } <--> eth[i].phys;
        }
        for i=0..numLoInterfaces-1 {
            li.out++ --> lo[i].upperLayerIn;
            lo[i].upperLayerOut --> li.in++;
        }

        for i=0..sizeof(radioIn)-1 {
            wlan[i].upperLayerOut --> li.in++;
            wlan[i].upperLayerIn <-- li.out++;
        }

        for i=0..sizeof(ethg)-1 {
            eth[i].upperLayerOut --> li.in++;
            eth[i].upperLayerIn <-- li.out++;
        }
        for i=0..numTunInterfaces-1 {
            tun[i].upperLayerOut --> li.in++;
            tun[i].upperLayerIn <-- li.out++;
        }

        for i=0..numVirtInterfaces-1 {
            virt[i].upperLayerOut --> li.in++;
            virt[i].upperLayerIn <-- li.out++;
        }
}
