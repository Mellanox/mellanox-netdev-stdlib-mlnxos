#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx-os image install handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:mlnx_installed_img).provide :mlnxos do

  defaultfor :netdev_type => :MLNX
  @doc = "Manage fetched MLNX-OS images"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  mk_resource_methods

  def name=(value)
    @property_flush[:name] = value
  end

  def is_next_boot=(value)
    @property_flush[:is_next_boot] = value
  end

  def configuration_write=(value)
    @property_flush[:configuration_write] = value
  end

  def force_reload=(value)
    @property_flush[:force_reload] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :installed_img, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :installed_img, resource[:name])
    @property_hash.clear
    @property_flush.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :installed_img, name)[name]
      if value.nil?
        new(:name => name.to_s,
        :ensure => :absent
        )
      else
        new(:name => name.to_s,
        :ensure => :present,
        :is_next_boot => value[:is_next_boot]
        )
      end
    end

  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    imgs = instances(resources)
    resources.each do |name, params|
      if provider = imgs.find { |img| img.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      MLNX::netdev_handler(:PUT, :installed_img, resource[:name],  build_params(resource)) \
                                                                      if !@property_flush.empty?
    end
    @property_hash = resource.to_hash
  end

  def build_params(resource)
    params = {}
    params[:is_next_boot] = resource[:is_next_boot]
    params[:configuration_write] = resource[:configuration_write]
    params[:force_reload] = resource[:force_reload]
    params
  end

end
