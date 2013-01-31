#!/usr/bin/ruby
$:.unshift("./lib")
require "crazy_gin"

@ban = Shogiban.new(File.read("./data/quiz01.txt"))
CrazyGin.init({:turn => 20, :initial_shogiban => @ban})

p CrazyGin.solve
