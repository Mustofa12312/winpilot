package api

import (
	"fmt"
	"log"
	"net"
	"os"
	"strings"
)

// StartUDPDiscoveryServer starts a UDP server to reply to mobile app auto-discovery pings.
func StartUDPDiscoveryServer(port int) {
	addr := net.UDPAddr{
		Port: port,
		IP:   net.ParseIP("0.0.0.0"),
	}

	conn, err := net.ListenUDP("udp", &addr)
	if err != nil {
		log.Printf("Failed to start UDP discovery server: %v\n", err)
		return
	}
	defer conn.Close()

	fmt.Printf("  📡 UDP Discovery Server listening on port %d\n", port)
	
	hostname, _ := os.Hostname()
	if hostname == "" {
		hostname = "WinPilot-PC"
	}

	buf := make([]byte, 1024)
	for {
		n, remoteAddr, err := conn.ReadFromUDP(buf)
		if err != nil {
			log.Printf("Error reading UDP: %v\n", err)
			continue
		}

		msg := strings.TrimSpace(string(buf[:n]))
		if msg == "WINPILOT_DISCOVER" {
			reply := fmt.Sprintf("WINPILOT_HERE|%s", hostname)
			conn.WriteToUDP([]byte(reply), remoteAddr)
		}
	}
}
