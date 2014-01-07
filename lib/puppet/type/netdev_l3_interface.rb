##
# Puppet Module  : netdev
# File           : puppet/type/netdev_l3_interface.rb
# Version        : 2013-12-16
# Description    :
#
#    This file contains the Type definition for the network
#    device  layer 3 interface.
#
##

Puppet::Type.newtype(:netdev_l3_interface) do

  @doc = "Ethernet layer3 interface"

  ensurable
  feature :activable, "The ability to activate/deactive configuration"

  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------

  newparam(:name, :namevar=>true) do
    desc "The interface name"
  end

  ##### -------------------------------------------------------------
  ##### Properties
  ##### -------------------------------------------------------------

  newproperty(:method) do
    newvalues(:static, :dhcp)
  end

  newproperty(:ipaddress) do
    require 'ipaddr'
    validate do |value|
      begin
        IPAddr.new value
      rescue ArgumentError
        raise "Invalid IP address #{value}"
      end
    end
  end

  newproperty(:netmask) do
  end

  newproperty(:gateway) do
  end

  ##### -------------------------------------------------------------
  ##### Auto requires
  ##### -------------------------------------------------------------

  autorequire(:netdev_device) do
    netdev = catalog.resources.select{ |r| r.type == :netdev_device }[0]
    netdev.title if netdev  # returns the name of the netdev_device resource
  end

  autorequire(:netdev_router_ospf) do
    routers = catalog.resources.select{ |r| r.type == :netdev_router_ospf }
    ['default']
  end

end
