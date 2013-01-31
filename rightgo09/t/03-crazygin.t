use strict;
use warnings;
use Test::More;
use Test::Output;
use File::Spec;
use File::Basename;
use CrazyGin;

stdout_is {
  CrazyGin->run(File::Spec->catfile(dirname(__FILE__), '..', 'data', 'data01.txt'));
} 379273749374/95367431640625 . "\n";

done_testing;
