=begin
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
* Puppet Module  : netdev_stdlib_mlnxos
* Author         : David Slama, Aviram Bar-Haim
* File           : puppet/type/mlnx_img.rb
* Version        : 1.0.0
* Description    :
*
*    This file contains the Type definition for an installed image on a device.
*
=end

Puppet::Type.newtype(:mlnx_installed_img) do

  @doc = "Manages an image installation on a network device."

  ensurable

  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------

  newparam(:name, :namevar=>true) do
    desc "The version/file name"
  end

  ##### -------------------------------------------------------------
  ##### Properties
  ##### -------------------------------------------------------------

  newproperty(:is_next_boot) do
    desc "Ensures that the installed image is the next boot partition"
    defaultto(:yes)
    newvalues(:yes, :no)
  end

  newproperty(:configuration_write) do
    desc "Write configurations on reload (if reload is necessary)"
    defaultto(:no)
    newvalues(:yes, :no)
  end

  newproperty(:force_reload) do
    desc "Reload if image is in other partition"
    defaultto(:no)
    newvalues(:yes, :no)
  end

  ##### -------------------------------------------------------------
  ##### Auto requires
  ##### -------------------------------------------------------------

  autorequire(:netdev_device) do
    netdev = catalog.resources.select{ |r| r.type == :netdev_device }[0]
    netdev.title if netdev  # returns the name of the netdev_device resource
  end

  def get_type_resources_names(type)
    type = type.capitalize!
    requires = []
    catalog.resources.each {|d|
          if (d.class.to_s == "Puppet::Type::#{type}")
             requires << d.name
          end
    }
    requires
  end

  autorequire(:netdev_vlan) do
    get_type_resources_names('netdev_vlan')
  end

  autorequire(:netdev_lag) do
    get_type_resources_names('netdev_lag')
  end

  autorequire(:netdev_interface) do
    get_type_resources_names('netdev_interface')
  end

  autorequire(:netdev_l2_interface) do
    get_type_resources_names('netdev_l2_interface')
  end

  autorequire(:netdev_l3_interface) do
    get_type_resources_names('netdev_l3_interface')
  end

  autorequire(:netdev_ospf_area) do
    get_type_resources_names('netdev_ospf_area')
  end

  autorequire(:netdev_ospf_interface) do
    get_type_resources_names('netdev_ospf_interface')
  end

  autorequire(:netdev_router_ospf) do
    get_type_resources_names('netdev_router_ospf')
  end

  autorequire(:mlnx_protocol) do
   get_type_resources_names('mlnx_protocol')
  end

  autorequire(:mlnx_fetched_img) do
    get_type_resources_names('mlnx_fetched_img')
  end

end
