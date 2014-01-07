#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx router OSPF configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_router_ospf).provide :mlnxos do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage netdev router ospf on a switch"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def name=(value)
    @property_flush[:name] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :router_ospf, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :router_ospf, resource[:name])
    @property_hash.clear
    @property_flush.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :router_ospf, name)[name]
      if value.nil?
        new(:name => name.to_s,
        :ensure => :absent
        )
      else
        new(:name => name.to_s,
        :ensure => :present
        )
      end
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    routers = instances(resources)
    resources.each do |name, params|
      if provider = routers.find { |router| router.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :router_ospf, resource[:name],  build_params(resource)) if !@property_flush.empty?
    end
    @property_hash = resource.to_hash
  end

  def build_params(resource)
    params = {}
    params
  end

end
