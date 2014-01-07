#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx l2_interface configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_l2_interface).provide(:mlnxos) do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage MLNX switchport interfaces"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def vlan_tagging=(value)
    @property_flush[:vlan_tagging] = value
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def tagged_vlans=(value)
    @property_flush[:tagged_vlans] = value
  end

  def untagged_vlan=(value)
    @property_flush[:untagged_vlan] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :l2_interface, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :l2_interface, resource[:name])
    @property_hash.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :l2_interface, name)[name]
      if value.nil?
        new(:name => name.to_s,
        :ensure => :absent
        )
      else
        new(:name => name,
        :ensure => :present,
        :vlan_tagging => value[:vlan_tagging],
        :descripton => value[:description],
        :tagged_vlans => value[:tagged_vlans],
        :untagged_vlan => value[:untagged_vlan]
        )
      end
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")

    interfaces = instances(resources)
    resources.each do |name, params|
      if provider = interfaces.find { |interface| interface.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end

  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if (@property_flush and (resource[:ensure] != :absent))
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :l2_interface, resource[:name], build_params(resource))
    end
    @property_hash = resource.to_hash

  end

  def build_params(resource)
    params = {}
    params[:vlan_tagging] = resource[:vlan_tagging]
    params[:description] = resource[:description]
    params[:tagged_vlans] = resource[:tagged_vlans].flatten
    params[:untagged_vlan] = resource[:untagged_vlan]
    params
  end

end
