#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use CrazyGin;

@ARGV || die "Usage: $0 [path]\n";

CrazyGin->run($ARGV[0]);
