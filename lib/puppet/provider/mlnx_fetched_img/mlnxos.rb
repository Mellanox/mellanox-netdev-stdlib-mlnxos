#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx-os image download handler
#
# Version 1.0.0
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Puppet::Type.type(:mlnx_fetched_img).provide :mlnxos do

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

  def location=(value)
    @property_flush[:location] = value
  end

  def host=(value)
    @property_flush[:host] = value
  end

  def password=(value)
    @property_flush[:password] = value
  end

  def user=(value)
    @property_flush[:user] = value
  end

  def protocol=(value)
    @property_flush[:protocol] = value
  end

  def force_delete=(value)
    @property_flush[:force_delete] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    MLNX::netdev_handler(:PUT, :fetched_img, resource[:name], build_params(resource))
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    MLNX::netdev_handler(:DELETE, :fetched_img, resource[:name])
    @property_hash.clear
    @property_flush.clear
  end

  def self.instances(resources)
    Puppet.debug("Searching device for resources")
    resources.keys.each.collect do |name|
      value = MLNX::netdev_handler(:GET, :fetched_img, name)[name]
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
    imgs = instances(resources)
    resources.each do |name, params|
      if provider = imgs.find { |img| img.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    # image fetch can only be created or deleted
    # there is no sense in update this resource,
    # therefore there is implementation in flush
    Puppet.debug("#{self.resource.type}: FLUSH Nothing to Do")
  end

  def build_params(resource)
    params = {}
    params[:location] = resource[:location]
    params[:host] = resource[:host]
    params[:password] = resource[:password]
    params[:user] = resource[:user]
    params[:protocol] = resource[:protocol]
    params[:force_delete] = resource[:force_delete]
    params
  end

end
