# FortiGate BGP VPN Configuration Documentation

## Introduction

This document provides a detailed explanation of the BGP configuration for two VPN connections, a primary and a secondary, to AWS. These configurations are for a FortiGate firewall. The files `Primary VPN.tf` and `Secondary VPN.tf` contain the configuration commands for the FortiGate router.

----

## Primary VPN Configuration (`Primary VPN.tf`)

This section details the BGP configuration for the primary VPN connection.

### BGP Router Configuration

*   `config router bgp`: Enters the BGP configuration mode on the FortiGate.
*   `set as 205111`: Sets the local Autonomous System (AS) number to 205111.
*   `set router-id 1.1.1.1`: Sets the BGP router ID to 1.1.1.1. This is a unique identifier for the router in the BGP domain.
*   `set keepalive-timer 10`: Sets the keepalive timer to 10 seconds. Keepalive messages are sent to the BGP peer every 10 seconds to ensure the connection is active.
*   `set holdtime-timer 30`: Sets the holdtime timer to 30 seconds. If no keepalive messages are received from the peer within 30 seconds, the connection is considered down.
*   `set ebgp-multipath enable`: Enables eBGP multipath routing, allowing the use of multiple paths to the same destination.
*   `set additional-path enable`: Enables the BGP additional paths feature, which allows the router to receive multiple paths for the same prefix.
*   `set scan-time 30`: Sets the BGP scanner time to 30 seconds. The BGP scanner checks the BGP table for validity.
*   `set graceful-restart enable`: Enables graceful restart, which allows the BGP session to be maintained during a router restart.
*   `set additional-path-select 4`: Allows the selection of up to 4 additional paths to be advertised to BGP neighbors.

### BGP Neighbor Configuration

*   `config neighbor`: Enters the BGP neighbor configuration mode.
*   `edit "169.254.106.229"`: Defines a new BGP neighbor with the IP address 169.254.106.229.
*   `set advertisement-interval 2`: Sets the BGP advertisement interval to 2 seconds.
*   `set attribute-unchanged med`: Preserves the MED (Multi-Exit Discriminator) attribute when advertising routes.
*   `set activate6 disable`: Disables the IPv6 address family for this neighbor.
*   `set capability-dynamic enable`: Enables dynamic capability negotiation with the neighbor.
*   `set capability-graceful-restart enable`: Enables graceful restart capability for this neighbor.
*   `set link-down-failover enable`: Enables link-down failover for this neighbor.
*   `set stale-route enable`: Enables stale route handling for this neighbor.
*   `set soft-reconfiguration enable`: Enables soft reconfiguration, allowing for policy changes without resetting the BGP session.
*   `set description "AWS"`: Sets a description for the neighbor.
*   `set interface "VPN-AWS-0"`: Specifies the interface to use for the BGP session.
*   `set maximum-prefix 100`: Sets the maximum number of prefixes that can be received from this neighbor to 100.
*   `set remote-as 64513`: Sets the remote AS number to 64513 (AWS's AS number).
*   `set local-as 64512`: Sets the local AS number to 64512 for this specific neighbor relationship.
*   `set retain-stale-time 9`: Sets the time to retain stale routes to 9 seconds.
*   `set route-map-in "AWS-To-Fortigate-in-Primary"`: Applies the specified route map to incoming routes from this neighbor.
*   `set route-map-out "Fortigate_To_Partners_Out_Primary"`: Applies the specified route map to outgoing routes to this neighbor.
*   `set keep-alive-timer 10`: Sets the keepalive timer to 10 seconds for this neighbor.
*   `set holdtime-timer 30`: Sets the holdtime timer to 30 seconds for this neighbor.
*   `set connect-timer 10`: Sets the connect timer to 10 seconds.
*   `set update-source "VPN-AWS-0"`: Specifies the source interface for BGP updates.
*   `set restart-time 10`: Sets the graceful restart time to 10 seconds.
*   `set additional-path receive`: Configures the neighbor to receive additional paths.
*   `next`: Ends the configuration for this neighbor.
*   `end`: Exits the neighbor configuration mode.

### Graceful Restart Timers

*   `set graceful-restart-time 30`: Sets the global graceful restart time to 30 seconds.
*   `set graceful-stalepath-time 60`: Sets the time to hold stale paths to 60 seconds.
*   `set graceful-update-delay 15`: Sets the delay for sending BGP updates after a graceful restart to 15 seconds.
*   `end`: Exits the BGP configuration mode.

---

## Secondary VPN Configuration (`Secondary VPN.tf`)

This section details the BGP configuration for the secondary VPN connection. The configuration is very similar to the primary, with a few key differences noted below.

### BGP Router Configuration

The BGP router configuration is identical to the primary VPN configuration.

### BGP Neighbor Configuration

*   `config neighbor`: Enters the BGP neighbor configuration mode.
*   `edit "169.254.40.9"`: Defines a new BGP neighbor with the IP address 169.254.40.9.
*   `set interface "VPN-AWS-1"`: Specifies the interface to use for the BGP session.
*   `set update-source "VPN-AWS-1"`: Specifies the source interface for BGP updates.
*   `set route-map-in "AWS-To-Fortigate-in-Secondary"`: Applies a different route map for incoming routes, which has a lower local preference.
*   `set route-map-out "Fortigate_To_Partners_Out_Secondary"`: Applies a different route map for outgoing routes.

All other neighbor settings are the same as the primary VPN neighbor.

---

## Prefix List Configuration

*   `config router prefix-list`: Enters the prefix list configuration mode.
*   `edit "AWS-Prefix"`: Creates a new prefix list named "AWS-Prefix".
*   `config rule`: Enters the rule configuration mode for the prefix list.
*   `edit 1`: Creates a new rule with ID 1.
*   `set prefix 10.10.0.0 255.255.0.0`: Defines a prefix of 10.10.0.0/16 to be matched by this rule.
*   `unset ge`: Removes the "greater than or equal to" prefix length condition.
*   `unset le`: Removes the "less than or equal to" prefix length condition.
*   `next`: Ends the configuration for this rule.
*   `end`: Exits the rule configuration mode.
*   `next`: Ends the configuration for this prefix list.
*   `end`: Exits the prefix list configuration mode.

---

## Route Map Configuration

### Primary Route Map (`AWS-To-Fortigate-in-Primary`)

*   `config router route-map`: Enters the route map configuration mode.
*   `edit "AWS-To-Fortigate-in-Primary"`: Creates a new route map for the primary connection.
*   `config rule`: Enters the rule configuration mode.
*   `edit 1`: Creates a rule to process routes from AWS.
*   `set match-ip-address "AWS-Prefix"`: Matches routes that are in the "AWS-Prefix" prefix list.
*   `set set-local-preference 1000`: Sets the local preference of matched routes to 1000. This is a high value, making this path the preferred one.
*   `set set-metric 50`: Sets the metric (MED) of matched routes to 50.
*   `set set-weight 1000`: Sets the weight of matched routes to 1000. This is a locally significant attribute that influences the best path selection.
*   `next`: Ends rule 1.
*   `edit 2`: Creates a rule to block all other routes.
*   `set match-ip-address "block-all"`: Matches a prefix list that should contain a deny-all rule (this prefix list is not defined in the provided files).
*   `next`: Ends rule 2.
*   `end`: Exits rule configuration mode.
*   `next`: Ends the route map configuration.
*   `end`: Exits the route map configuration mode.

### Secondary Route Map (`AWS-To-Fortigate-in-Secondary`)

*   `edit "AWS-To-Fortigate-in-Secondary"`: Creates a new route map for the secondary connection.
*   `set set-local-preference 900`: Sets the local preference to 900. This is lower than the primary's 1000, making this the backup path.
*   `set set-metric 100`: Sets the metric to 100, which is higher (less preferred) than the primary's 50.
*   `set set-weight 900`: Sets the weight to 900, which is lower than the primary's 1000.

The rest of the secondary route map configuration is the same as the primary.

---

## Summary

This configuration establishes a primary and a secondary BGP-based VPN connection to an AWS environment. The primary connection is preferred due to a higher local preference (1000 vs 900), a higher weight (1000 vs 900), and a lower MED (50 vs 100). This setup ensures redundant connectivity to AWS, with traffic automatically failing over to the secondary connection if the primary connection goes down. The prefix list `AWS-Prefix` is used to filter and apply specific attributes to the `10.10.0.0/16` network from AWS.
# bgp-01
# bgp
# bgp
# bgp
# bgp
# bgp
# bgp-route
# bgp-test
