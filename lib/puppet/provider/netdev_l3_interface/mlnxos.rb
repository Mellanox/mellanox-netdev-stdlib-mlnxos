#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx l3_interface configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_l3_interface).provide(:mlnxos) do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage MLNX layer 3 interfaces"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def method=(value)
    @property_flush[:method] = value
  end

  def ipaddress=(value)
    @property_flush[:ipaddress] = value
  end

  def netmask=(value)
    @property_flush[:netmask] = value
  end

  def gateway=(value)
    @property_flush[:gateway] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :l3_interface, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :l3_interface, resource[:name])
    @property_hash.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :l3_interface, name)[name]
      if value.nil?
        new(:name => name.to_s,
        :ensure => :absent
        )
      else
        new(:name => name.to_s,
        :ensure => :present,
        :method => value[:method],
        :ipaddress => value[:ipaddress],
        :netmask => value[:netmask],
        :gateway => value[:gateway]
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
        netmask_convent = Area_validation.num_to_mask(resources[name][:netmask].gsub("/",''))
        resources[name][:netmask] = netmask_convent
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush and resource[:ensure].to_sym == :present
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :l3_interface, resource[:name], build_params(resource))
    end
    @property_hash = resource.to_hash
  end

  def build_params(resource)
    params = {}
    params[:method] = resource[:method]
    params[:ipaddress] = resource[:ipaddress]
    params[:netmask] = resource[:netmask]
    params[:gateway] = resource[:gateway]
    params
  end

end
