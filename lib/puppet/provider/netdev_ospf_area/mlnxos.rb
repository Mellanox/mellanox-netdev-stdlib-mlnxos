#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx OSPF area configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_ospf_area).provide :mlnxos do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage netdev device ospf router on a switch"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def name=(value)
    @property_flush[:name] = value
  end

  def subnets=(value)
    @property_flush[:subnets] = value
  end

  def router_id=(value)
    @property_flush[:router_id] = value
  end

  def ospf_area_mode=(value)
    @property_flush[:ospf_area_mode] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :ospf_area, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :ospf_area, resource[:name])
    @property_hash.clear
    @property_flush.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
       value = MLNX::netdev_handler(:GET, :ospf_area, name)[name]
       if value.nil?
         new(:name => name.to_s, :ensure => :absent)
       else
         new(:name => name.to_s,
         :ensure => :present,
         :subnets => value[:subnets],
         :router_id => value[:router_id],
         :ospf_area_mode => value[:ospf_area_mode]
         )
       end
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    ospf_areas = instances(resources)
    resources.each do |name, params|
      if provider = ospf_areas.find { |area| area.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :ospf_area, resource[:name],  build_params(resource)) if !@property_flush.empty?
    end
    @property_hash = resource.to_hash
  end

  def build_params(resource)
    params = {}
    params[:subnets] = resource[:subnets].flatten
    params[:router_id] = resource[:router_id]
    params[:ospf_area_mode] = resource[:ospf_area_mode]
    params
  end

end
