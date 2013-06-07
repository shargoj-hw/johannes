require 'simplecov'
SimpleCov.start

$:<< File.join(File.dirname(__FILE__), '../src/game')
$:<< File.join(File.dirname(__FILE__), '../src/dsl')
$:<< File.join(File.dirname(__FILE__), '../src/')
