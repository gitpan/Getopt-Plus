require 5.005_62;
use strict;

use ExtUtils::MakeMaker;

WriteMakefile (
  NAME         => 'Getopt-Plus',
  VERSION      => '0.98',
  AUTHOR       => 'Martyn J. Pearce ',
  ABSTRACT     => 'Options wrapper with standard options, help system and more',
  PREREQ_PM    => +{ 
                     'List::Util' => '1.06',
                     'Class::MethodMaker' => '1.04',
                     'IPC::Run' => '0.44',
                     'Log::Info' => '1.13',
                     'Pod::Usage' => '1.12',
                     'IPC::Run' => '0.44',},
  EXE_FILES    => [qw(  )],
  # Need this to stop Makefile treating Build.PL as a producer of Build as a
  # target for 'all'.
  PL_FILES     => +{},
  clean        => +{ FILES => join(' ', qw( Build _build )) },
  realclean    => +{ FILES => join(' ', qw( Build.PL META.yml
                                            Makefile.PL
                                            SIGNATURE
                                            README INSTALL
                                            configure make-pm )) },
);
