#!@nushell@

const interface_name = "@interface_name@"
const route_table = "@route-table@"
const ip_priority = "@ip_priority@"

def apply_ip [] {
    let cmd = $in | str join "\n"
    print $cmd
    if "DRY_RUN" in $env {
        return
    }
    $cmd | ip -6 --batch -
}

export def "rule add" [] {
    ip -6 -json addr show dev $interface_name | from json 
        | get 0.addr_info | where scope == "global"
        | each {|addr| 
            $"rule add from ($addr.local)/($addr.prefixlen) table ($route_table) priority ($ip_priority)"
        }
        | apply_ip
}

export def "rule del" [] {
    ip -6 -json rule list priority $ip_priority | from json
        | each {|rule| $"rule del priority ($ip_priority)" } 
        | apply_ip
}

export def "rule update" [] {
    rule del
    rule add
}

def main [interface: string, action: string] {
    if $interface != $interface_name {
        return
    }
    match $action {
        "down" => { rule del }
        "dhcp6-change" => { rule update },
        _ => {}
    }
}