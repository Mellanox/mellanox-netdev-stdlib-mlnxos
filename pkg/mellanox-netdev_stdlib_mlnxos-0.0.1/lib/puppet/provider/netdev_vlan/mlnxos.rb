#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx vlan configurations handler
#
# Version 1.6
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_vlan).provide(:mlnxos) do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage MLNX VLAN"

  def initialize(value={})
    super(value)
  end

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("CREATE #{resource[:name]} with id #{resource[:vlan_id]}")
    MLNX::netdev_handler(:PUT, :vlan, resource[:vlan_id], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :vlan, @property_hash[:vlan_id])
    @property_hash.clear
  end

  def self.instances
    Puppet.debug("Searching device for resources")
    resp = MLNX::netdev_handler(:GET, :vlan)
    resp.each.collect do |key, value|
      new(:name => value[:name], :ensure => :present, :vlan_id => key)
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    vlans = instances
    resources.each do |name, params|
      if provider = vlans.find { |vlan| vlan.vlan_id == params[:vlan_id]}
        resources[name].provider = provider
      end
    end
  end

  def build_params(resource)
    params = {}
    params[:name] = resource[:name]
    params[:vlan_id] = resource[:vlan_id]
    params
  end

end
