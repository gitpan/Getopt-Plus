use 5.005_62;
use strict;

use File::Spec::Functions qw( catfile );

use constant MOD_REQS =>
  [ { name    => 'Pod::Usage',
      version => '1.12', },

    { name    => 'Class::MethodMaker',
      package => 'Class-MethodMaker',
      version => '1.04', },

    { name    => 'Log::Info',
      package => 'Log-Info',
      version => '1.09', },

    { name    => 'List::Util',
      package => 'Scalar-List-Utils',
      version => '1.06', },

    # Used by test.pm
    { name    => 'IPC::Run',
      package => 'IPC-Run',
      version => '0.44', },
  ];

use constant EXEC_REQS => [ ];

use constant NAME         => 'Getopt-Plus';
use constant VERSION_FROM => catfile (qw( lib Getopt Plus.pm ));
use constant AUTHOR       => 'Martyn J. Pearce fluffy@cpan.org';
use constant ABSTRACT     => 'Getopt wrapper with standard options, help system and more';

use FindBin 1.42 qw( $Bin );
use lib $Bin;
use make;
