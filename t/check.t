# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Getopt::Plus

This package tests the check/initialize/finalize/end utility of Getopt::Plus

=cut

use Env                        qw( @PATH );
use File::Spec::Functions  1.1 qw( catdir );
use FindBin               1.42 qw( $Bin );
use Test                  1.13 qw( ok plan );

use lib $Bin;
use test  qw( LIB_DIR
              PERL );
use test2 qw( simple_run_test );

BEGIN {
  # 1 for compilation test,
  plan tests  => 29,
       todo   => [],
}

# ----------------------------------------------------------------------------

=head2 Test 1: compilation

This test confirms that the test script and the modules it calls compiled
successfully.

=cut

unshift @PATH, catdir $Bin, 'bin';

ok 1, 1, 'compilation';

# -------------------------------------

=head2 Test 2--4: test-script-2

Run the test script.

( 1) Check that the script ran okay (and hence compiled okay)
( 2) Check that the output is as expected (and hence that the expected
     components ran in the order check/initialize/finalize/end)
( 3) Check that no extra files were created

=cut

{
  my ($out, $err) = "";
  my $fn = 'normal';
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2'],
                                     '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  );
}

# -------------------------------------

=head2 Test 5--8: fail1

Run the test script, with the --fail1 option

( 1) Check that the script exited code 3
( 2) Check that the output is as expected (and hence that the expected
     components ran in the expected order, with no finalize (since initialize
     failed)
( 3) Check that no extra files were created
( 4) Check "Squeek" was emitted on stderr

=cut

{
  my ($out, $err) = "";
  my $fn = 'fail1';
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2', '--fail1'],
                                     '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 3,
                  );
  ok $err, "Squeek\ninitialize failed\n",                        'fail1 ( 4)';
}

# -------------------------------------

=head2 Test 9--12: fail2

Run the test script, with the --fail2 option

( 1) Check that the script exited code 255
( 2) Check that the output is as expected (and hence that the expected
     components ran in the expected order, with no finalize (since initialize
     failed)
( 3) Check that no extra files were created
( 4) Check "Squeak" was emitted on stderr

=cut

{
  my ($out, $err) = "";
  my $fn = 'fail2';
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2', '--fail2'],
                                     '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 255,
                  );
  ok $err, "Squawk\ninitialize failed\n",                        'fail2 ( 4)';
}

# -------------------------------------

=head2 Test 13--16: fail3

Run the test script, with the --fail3 option

( 1) Check that the script exited code 0
( 2) Check that the output is as expected (and hence that the expected
     components ran in the expected order, with finalize or initialize
     (since check succeeded)
( 3) Check that no extra files were created
( 4) Check "Check failed" was emitted on stderr

=cut

{
  my ($out, $err) = "";
  my $fn = 'fail3';
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2', '--fail3'],
                                     '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 0,
                  );
  ok $err, '',                                                   'fail3 ( 4)';
}

# -------------------------------------

=head2 Test 17--20: msg

Run the test script, with the --msg option

( 1) Check that the script exited code 255
( 2) Check that the output is as expected (and hence that the expected
     components ran in the expected order, with no finalize or initialize
     (since check failed)
( 3) Check that no extra files were created
( 4) Check "Message\nCheck failed\n" was emitted on stderr

=cut

{
  my ($out, $err) = "";
  my $fn = 'msg';
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2', '--msg'],
                                     '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 255,
                  );
  ok $err, "Message\ncheck failed\n",                              'msg ( 4)';
}

# -------------------------------------

=head2 Test 21--23: help

Run the test script, with the --help option

( 1) Check that the script exited code 255
( 2) Check that the output is as expected (and hence that end ran)
( 3) Check that no extra files were created

=cut

{
  my ($out, $err) = "";
  my $fn = 'help';
  local $ENV{COLUMNS} = 80;
  simple_run_test(runargs        => [[PERL, -S => 'test-script-2', '--help'],
                                     # Redirect STDIN to force help to
                                     # default columns
                                     '<', \undef, '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 2,
                  );
}

# -------------------------------------

=head2 Test 24--26: secondary

Test the alternative modes, with the --secondary flag

( 1) Check that the script exited code 0
( 2) Check that the output is as expected
( 3) Check that no extra files were created

=cut

{
  my ($out, $err) = "";
  my $fn = 'secondary';
  simple_run_test(runargs        => [[PERL, -S =>'test-script-2','--secondary'],
                                     # Redirect STDIN to force help to
                                     # default columns
                                     '<', \undef, '>', $fn, '2>', \$err],
                  name           => 'test-script-2',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 0,
                  );
}

# -------------------------------------

=head2 Test 24--26: args_done

Test that the args_done callback operates

( 1) Check that the script exited code 0
( 2) Check that the output is as expected
( 3) Check that no extra files were created

=cut

{
  my ($out, $err) = "";
  my $fn = 'args_done';
  simple_run_test(runargs        => [[PERL, -S =>'test-script-4','--secondary',
                                      'blibble', 'blobble',],
                                     # Redirect STDIN to force help to
                                     # default columns
                                     '<', \undef, '>', $fn, '2>', \$err],
                  name           => 'test-script-4',
                  errref         => \$err,
                  checkfiles     => [ $fn ],
                  testref_subdir => 'check',
                  exitcode       => 0,
                  );
}

# ----------------------------------------------------------------------------
