defmodule VintageNet.ConfigEthTest do
  use ExUnit.Case
  alias VintageNet.Interface.RawConfig
  alias VintageNet.Technology.Ethernet
  import VintageNetTest.Utils

  test "create a wired ethernet configuration" do
    input = %{type: VintageNet.Technology.Ethernet, ipv4: %{method: :dhcp}, hostname: "unittest"}

    output = %RawConfig{
      ifname: "eth0",
      type: VintageNet.Technology.Ethernet,
      source_config: input,
      child_specs: [{VintageNet.Interface.ConnectivityChecker, "eth0"}],
      files: [
        {"/tmp/network_interfaces.eth0", dhcp_interface("eth0", "unittest")}
      ],
      up_cmd_millis: 60_000,
      up_cmds: [{:run, "/sbin/ifup", ["-i", "/tmp/network_interfaces.eth0", "eth0"]}],
      down_cmds: [{:run, "/sbin/ifdown", ["-i", "/tmp/network_interfaces.eth0", "eth0"]}]
    }

    assert output == Ethernet.to_raw_config("eth0", input, default_opts())
  end

  test "create a wired ethernet configuration with static IP" do
    input = %{
      type: VintageNet.Technology.Ethernet,
      ipv4: %{
        method: :static,
        addresses: [
          %{address: "192.168.0.2", netmask: "255.255.255.0", gateway: "192.168.0.1"}
        ],
        dns_servers: ["1.1.1.1", "8.8.8.8"],
        search_domains: ["test.net"]
      }
    }

    interfaces_content = """
    iface eth0 inet static
      address 192.168.0.2
      netmask 255.255.255.0
      gateway 192.168.0.1
      dns_nameservers 1.1.1.1 8.8.8.8
      dns-search test.net
    """

    output = %RawConfig{
      ifname: "eth0",
      type: VintageNet.Technology.Ethernet,
      source_config: input,
      child_specs: [{VintageNet.Interface.ConnectivityChecker, "eth0"}],
      files: [{"/tmp/network_interfaces.eth0", interfaces_content}],
      up_cmd_millis: 60_000,
      up_cmds: [{:run, "/sbin/ifup", ["-i", "/tmp/network_interfaces.eth0", "eth0"]}],
      down_cmds: [{:run, "/sbin/ifdown", ["-i", "/tmp/network_interfaces.eth0", "eth0"]}]
    }

    # TODO!!!!!
    # assert output == Ethernet.to_raw_config("eth0"input, default_opts())
  end
end
