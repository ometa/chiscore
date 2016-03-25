#!/usr/bin/env ruby

require 'irb'
require 'fileutils'

root = FileUtils.pwd
$:<< root << File.join(root, "lib")

require 'app'

IRB.start
