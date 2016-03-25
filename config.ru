root = File.dirname(__FILE__)
$: << root << File.join(root, "lib")

require 'app'
require 'logger'

class ChiLog < Logger
  def write(msg)
    info(msg)
  end
end

logger = ChiLog.new('rack.log')
use Rack::CommonLogger, logger

run ChiScore::App
