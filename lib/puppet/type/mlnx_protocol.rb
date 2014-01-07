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
* File           : puppet/type/mlnx_protocol.rb
* Version        : 1.0.0
* Description    :
*
*    This file contains the Type definition for the network
*    device protocol enable/disable handler.
*
=end

Puppet::Type.newtype(:mlnx_protocol) do
  @doc = "Network Device protocol handler"

  ensurable

  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------

  newparam(:name, :namevar=>true) do
    desc "The name of the protocol to enable/disable"
    newvalues(:ip_routing, :spanning_tree, :lldp, :snmp)
  end

  ##### -------------------------------------------------------------
  ##### Auto requires
  ##### -------------------------------------------------------------

  autorequire(:netdev_device) do
    netdev = catalog.resources.select{ |r| r.type == :netdev_device }[0]
    netdev.title if netdev  # returns the name of the netdev_device resource
  end

end
