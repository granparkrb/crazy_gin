use strict;
use warnings;
use Test::More;
use CrazyGin;

new_ok 'Masu';
my $shogiban = new_ok 'Shogiban', ['O', ' ', 'G', 'F'];
subtest 'koma' => sub {
  is $shogiban->[0][0]->koma, 'O';
  is $shogiban->[1][0]->koma, ' ';
  is $shogiban->[2][0]->koma, 'G';
  is $shogiban->[3][0]->koma, 'F';
};

subtest 'height' => sub {
  cmp_ok $shogiban->[0][0]->height, '==', 0;
  cmp_ok $shogiban->[1][0]->height, '==', 1;
  cmp_ok $shogiban->[2][0]->height, '==', 2;
  cmp_ok $shogiban->[3][0]->height, '==', 3;
};

subtest 'width' => sub {
  cmp_ok $shogiban->[0][0]->width, '==', 0;
  cmp_ok $shogiban->[1][0]->width, '==', 0;
  cmp_ok $shogiban->[2][0]->width, '==', 0;
  cmp_ok $shogiban->[3][0]->width, '==', 0;
};

subtest 'stash' => sub {
  cmp_ok $shogiban->[0][0]->stash, '==', 0;
  cmp_ok $shogiban->[1][0]->stash, '==', 0;
  cmp_ok $shogiban->[2][0]->stash, '==', 0;
  cmp_ok $shogiban->[3][0]->stash, '==', 0;
};

done_testing;
