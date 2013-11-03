#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx device handling class
# Version 1.6
#
# Created on Aug 1, 2013
#
# @authors: {David Slama, Aviram Bar-Haim}

Puppet::Type.type(:netdev_device).provide(:mlnxos) do
  defaultfor :netdev_type => :MLNX
  @doc = "MLNX Device Managed Resource for auto-require"


  ##### ------------------------------------------------------------
  ##### Device provider methods expected by Puppet
  ##### ------------------------------------------------------------

  def exists?
    true
  end

  def create
    raise "Unreachable: NETDEV create"
  end

  def destroy
    raise "Unreachable: NETDEV destroy"
  end

end
