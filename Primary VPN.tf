config router bgp
    set as 205111
    set router-id 1.1.1.1
    set keepalive-timer 10
    set holdtime-timer 30
    set ebgp-multipath enable
    set additional-path enable
    set scan-time 30
    set graceful-restart enable
    set additional-path-select 4
    config neighbor
        edit "169.254.106.229"
            set advertisement-interval 2
            set attribute-unchanged med
            set activate6 disable
            set capability-dynamic enable
            set capability-graceful-restart enable
            set link-down-failover enable
            set stale-route enable
            set soft-reconfiguration enable
            set description "AWS"
            set interface "VPN-AWS-0" <---
            set maximum-prefix 100
            set remote-as 64513
            set local-as 64512
            set retain-stale-time 9
            set route-map-in "AWS-To-Fortigate-in-Primary"
            set route-map-out "Fortigate_To_Partners_Out_Primary"
            set keep-alive-timer 10
            set holdtime-timer 30
            set connect-timer 10
            set update-source "VPN-AWS-0" <---
            set restart-time 10
            set additional-path receive
        next
    end
    set graceful-restart-time 30
    set graceful-stalepath-time 60
    set graceful-update-delay 15
end

============================================================
Prifix
============================================================

config router prefix-list
    edit "AWS-Prefix"
        config rule
            edit 1
                set prefix 10.10.0.0 255.255.0.0
                unset ge
                unset le
            next
        end
    next
end

=============================================================
Route-MAP
=============================================================
config router route-map
    edit "AWS-To-Fortigate-in-Primary"
        config rule
            edit 1
                set match-ip-address "AWS-Prefix"
                set set-local-preference 1000
                set set-metric 50
                set set-weight 1000
            next
            edit 2
                set match-ip-address "block-all"
            next
        end
    next
end
 

==============================================================