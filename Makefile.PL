use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME => 'cloud_diary',
  VERSION   => '0.01',
  PREREQ_PM => {
    'Mojolicious' => '9.38',
    'DBD::SQLite' => '1.74',
    'DBIx::Connector' => '0.59'
  },
  test => {TESTS => 't/*.t'}
);
