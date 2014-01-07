#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx interface configuration handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:netdev_interface).provide(:mlnxos) do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage MLNX physical interfaces"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def admin=(value)
    @property_flush[:admin] = value
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def mtu=(value)
    @property_flush[:mtu] = value
  end

  def speed=(value)
    @property_flush[:speed] = value
  end

  def duplex=(value)
    @property_flush[:duplex] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :interface, resource[:name], build_params(resource))
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :interface, resource[:name])
  end

  def self.instances(resources)
    Puppet.debug("Requesting resources from the device")
    interfaces = {}
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :interface, name)[name]
      item = new(:name => name.to_s,
      :ensure => :present,
      :admin => value[:admin],
      :description => value[:description],
      :mtu => value[:mtu],
      :speed => value[:speed],
      :duplex => value[:duplex]
      )
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch interface")
    interfaces = instances(resources)
    resources.each do |name, params|
      if provider = interfaces.find { |interface| interface.name == params[:name] }
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("Flushing changed parameters")
    MLNX::netdev_handler(:PUT, :interface, resource[:name], @property_flush) if @property_flush
    @property_hash = resource.to_hash
  end

  def build_params(resource)
    params = {}
    params[:admin] = resource[:admin]
    params[:description] = resource[:description]
    params[:mtu] = resource[:mtu]
    params[:speed] = resource[:speed]
    params[:duplex] = resource[:duplex]
    params
  end

end
