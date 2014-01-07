#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx protocol enable/disable configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:mlnx_protocol).provide :mlnxos do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage protocol enable/disable on a switch"

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
    MLNX::netdev_handler(:PUT, :protocol, resource[:name])
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :protocol, resource[:name])
    @property_hash.clear
    @property_flush.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :protocol, name)[name]
      if value.nil?
        new(:name => name, :ensure => :absent)
      else
        new(:name => name, :ensure => :present)
      end
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    protocols = instances(resources)
    resources.each do |name, params|
      if provider = protocols.find { |protocol| protocol.name == params[:name]}
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if not @property_flush.empty?
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :protocol, resource[:name])
    end
    @property_hash = resource.to_hash
  end

end
