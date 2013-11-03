#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Main mlnx facter handling class
# Version 1.6
#
# Created on Sep 12, 2013
#
# @authors: {Moshe Levi}

os = `/bin/uname -a`
require 'mlnx' if os =~ /MELLANOX/

Facter.add(:mlnxos_transport_version) do
  setcode do
    MLNX::get_version()
  end
end

Facter.add(:mlnxos_system_profile) do
  setcode do
    MLNX::system_profile()
  end
end

cmd = "/opt/tms/bin/cli -t \"show version\""
lines = Facter::Util::Resolution.exec(cmd)
lines = lines.split("\n")
lines.each do |line|
  next if line.empty?

  k,v = line.split(':')
  if !v.nil?
    k.downcase!
    k.gsub!(' ','_')

    fact_name = "mlnxos_" + k
    Facter.add(fact_name.to_sym) do
      setcode do
        v.strip
      end
    end
  end
end

