# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Getopt::Plus

This package tests the options writing utility of Getopt::Plus

=cut

use Env                        qw( @PATH );
use Fatal                 1.02 qw( open close );
use File::Spec::Functions  1.1 qw( catdir catfile rel2abs splitpath);
use FindBin               1.42 qw( $Bin );
use Test                  1.13 qw( ok plan );

use constant ME => rel2abs $0;

use lib $Bin;
use test  qw( DATA_DIR REF_DIR
              compare evcheck tmpnam );
use test2 qw( runcheck );

BEGIN {
  # 1 for compilation test,
  plan tests  => 270,
       todo   => [],
}

sub read_file {
  my ($fn) = @_;
  open my $fh, '<', $fn;
  local $/ = undef;
  my $contents = <$fh>;
  close $fh;
  return $contents;
}

# ----------------------------------------------------------------------------

=head2 Test 1: compilation

This test confirms that the test script and the modules it calls compiled
successfully.

=cut

unshift @PATH, catdir($Bin, 'bin');

ok 1, 1, 'compilation';

# -------------------------------------

=head2 Tests 2--7 : help options

Invoke test-script with the C<help>, C<longhelp>, C<man> options in turn

 n)   Test exit code is 2
 n+1) Test output is as expected

=cut

for my $opt (qw( help longhelp man )) {
  my ($out, $err) = ('') x 2;
  ok(runcheck([[$^X, '-S', 'test-script', "--$opt"],
               '<', \undef, '>', \$out, '2>', \$err],
              "test-script --$opt",
              \$err,
              2),
     1,                                                 "help options ($opt)");
  my $tmpnam = tmpnam;
  open my $tmpfh, '>', $tmpnam;
  local $\ = undef;
  print $tmpfh $out;
  close $tmpfh;
  ok compare($tmpnam, catfile(REF_DIR, 'test-script', $opt));
}

# -------------------------------------

=head2 Test 8: exit code assignment

Invoke test-script with the C<--weird> option.

1 ) Test exit code is 254

=cut

{
  my ($out, $err) = ('') x 2;
  ok(runcheck([[$^X, '-S', 'test-script', '-b', '--weird'],
               '<', \undef, '>', \$out, '2>', \$err],
              'exit code assignment',
              \$err,
              254),
     1,                                                'exit code assignment');
}

# -------------------------------------

=head2 Tests 9--16 : version options

Invoke test-script with the C<copyright>, C<version>, C<briefversion>, C<V>
options in turn

 n)   Test exit code is 2
 n+1) Test output is as expected

=cut

for my $opt (qw( copyright version briefversion V )) {
  my ($out, $err) = ('') x 2;
  ok(runcheck([[$^X, '-S', 'test-script',
                length($opt) > 1 ? "--$opt" : "-$opt" ],
               '<', \undef, '>', \$out, '2>', \$err],
              "test-script --$opt",
              \$err,
              2),
     1,                                                 "help options ($opt)");
  my $tmpnam = tmpnam;
  open my $tmpfh, '>', $tmpnam;
  local $\ = undef;
  print $tmpfh $out;
  close $tmpfh;
  ok compare($tmpnam, catfile(REF_DIR, 'test-script', $opt));
}

# -------------------------------------

=head2 Tests 17--28: arg linkage

Test the linkage of arg1, arg2 in test-script; call test-script with each
permutation of C<--arg1=bob>, C<--arg2=baz> (on/off).

( 1-- 3) Neither argument selected (control test)
( 4-- 6) --arg1=bob
( 7-- 9) --arg2=baz
(10--12) --arg1=bob --arg2=baz

=cut

{
  my $i = 1;
  for my $arg ({}, {qw(arg1 bob)}, {qw(arg2 2.0 )}, {qw(arg1 bob arg2 2.0)}) {
    my ($out, $err) = ('') x 2;
    my @opts = map {; "--$_=$arg->{$_}" } keys %$arg;
    ok(runcheck([[$^X, '-S', 'test-script', '-b', @opts],
                 '<', \undef, '>', \$out, '2>', \$err],
                sprintf("arg linkage (%s)", join(',', keys %$arg)),
                \$err,
                3),
       1,      sprintf("arg linkage (%s) (%2d)", join(',', keys %$arg), $i++));
    ok($out, join('',
                  map({; uc($_).": $arg->{$_}\n" } sort keys %$arg),
                  "BOB: 1\n"),
               sprintf("arg linkage (%s) (%2d)", join(',', keys %$arg), $i++));
    ok($err,
       "At least one arg must be given\n",
               sprintf("arg linkage (%s) (%2d)", join(',', keys %$arg), $i++));
  }
}

# -------------------------------------

=head2 Tests 29--204: fd/level

Check that the fd/level-options (verbose, progress, stats, debug) handle
combinations of fd, level, and filename correctly.

=cut

sub checkit {
  my ($opts, $expect_out, $expect_err, $tmpfn, $expect_fn) = @_;

  my $name = join ' ', @$opts;

  my($out, $err) = ('') x 2;
  ok(runcheck([[$^X, '-S', 'test-script', '-b',
                map(length($_) > 1 ? "--$_" : "-$_", @$opts),
                ME],
               '<', \undef, '>', \$out, '2>', \$err],
              $name, \$err), 1,                                  "$name ( 1)");
  ok $out, "BOB: 1\n$expect_out",                                "$name ( 2)";
  ok $err, $expect_err,                                          "$name ( 3)";
  if ( defined $tmpfn ) {
    ok read_file($tmpfn), $expect_fn,                            "$name ( 4)";
  } else {
    ok 1, 1,                                                     "$name ( 4)";
  }
}

{
  my $size = -s ME;
  my $mode = (stat ME)[2] & 07777;

  my %opts = (
              'verbose|v' => [sprintf("%s: %d\n",    ME, $size),
                              sprintf("%s: 0%04o\n", ME, $mode)],
              'progress'  =>
                [sprintf("[1/1 Arguments Done] Done Argument %s\n", ME)],
              'stats'     => [sprintf("S-%s: %d\n",    ME, $size),
                              sprintf("S-%s: 0%04o\n", ME, $mode)],
              'debug'     => [sprintf("process_fn: -->%s<--\n", ME)]
             );

  for my $opt (keys %opts) {
    my ($text, $text2) = @{$opts{$opt}};

    for my $name (split /\|/, $opt) {
      checkit([$name], '', $text);

      if ( length($name) > 1 ) {
        checkit(["$name=+1"],        '', $text);
        checkit(["$name=:1"],       $text, '');
        checkit(["$name=:2"],       '', $text);
        checkit(["$name=+1:1"],     $text, '');
        checkit(["$name=+1:2"],     '', $text);
        my $tmpfn = tmpnam;
        checkit(["$name=$tmpfn"],   '', '', $tmpfn, $text);
        $tmpfn = tmpnam;
        checkit(["$name=$tmpfn+1"], '', '', $tmpfn, $text);
      }

      if ( defined $text2 ) {
        my $alltext = join('', $text, $text2);
        checkit([$name, $name], '', $alltext);

        if ( length($name) > 1 ) {
          checkit(["$name=+2"],       '', $alltext);
          checkit(["$name=+2:1"],     $alltext, '');
          checkit(["$name=+2:2"],     '', $alltext);
          my $tmpfn = tmpnam;
          checkit(["$name=$tmpfn+2"], '', '', $tmpfn, $alltext);
        }
      }
    }
  }
}

# -------------------------------------

=head2 Tests 205--210: dry-run

Invoke test-script with & without the dry-run option.  Check that

 1) The exec works okay (exit status 0)
 2) The output is as expected
 3) Nothing appeared on stderr

=cut

{
  my($out, $err) = ('') x 2;
  # It requires an argument
  ok(runcheck([[$^X, '-S', 'test-script', ME, '--nobob'],
               '<', \undef, '>', \$out, '2>', \$err],
              '(no) dry-run', \$err), 1,                       'dry-run ( 1)');
  ok $out, "BOB: 0\n",                                         'dry-run ( 2)';
  ok $err, '',                                                 'dry-run ( 3)';
}

{
  my($out, $err) = ('') x 2;
  ok(runcheck([[$^X, '-S', 'test-script', '--dry-run', ME, '--nobob'],
               '<', \undef, '>', \$out, '2>', \$err],
              'dry-run', \$err), 1,                            'dry-run ( 4)');
  ok $out, "BOB: 0\nNothing doing\n",                          'dry-run ( 5)';
  ok $err, '',                                                 'dry-run ( 6)';
}

# -------------------------------------

=head2 Tests 211-249: help options

Invoke the --help switch with each option name.  Check that the output is as
expected.

=cut

for my $opt (qw( V briefversion copyright debug dry-run help longhelp man
                 progress stats v verbose version )) {
  my($out, $err) = ('') x 2;
  my $name = "help options ($opt)";
  my $expect = read_file(catfile REF_DIR, 'test-script', 'littlehelp', $opt);
  ok(runcheck([[$^X, '-S', 'test-script', "--help=$opt"],
               '<', \undef, '>', \$out, '2>', \$err],
              $name, \$err, 2), 1,                               "$name ( 1)");
  ok $out, $expect,                                              "$name ( 2)";
  ok $err, '',                                                   "$name ( 3)";
}

# -------------------------------------

=head2 Tests 250-252: bad help option

Invoke the --help switch with option name 'nosuchoption'.  Check that the
output is as expected.

=cut

{
  my($out, $err) = ('') x 2;
  my $name = "bad help option";
  my $opt = 'nosuchoption';
  ok(runcheck([[$^X, '-S', 'test-script', "--help=$opt"],
               '<', \undef, '>', \$out, '2>', \$err],
              $name, \$err, 3), 1,                               "$name ( 1)");
  ok $out, '',                                                   "$name ( 2)";
  ok $err, "No such option: nosuchoption\n",                     "$name ( 3)";
}

# -------------------------------------

=head2 Tests 253--270: arg linkage (b)

Test the linkage of b/bob in test-script; call test-script with each
of -b, --bob, --nobob (and --bob --nobob, --nobob -b)

( 1-- 3) Neither argument selected (control test); should fail
( 4-- 6) -b
( 7-- 9) --bob
(10--12) --nobob
(13--15) --bob --nobob
(16--18) --nobob -b

=cut

{
  my $i = 1;
  my $j = 0;
  for my $arg ([], ['-b'], ['--bob'], ['--nobob'],
               [qw(--bob --nobob)], [qw(--nobob --b)]) {
    my ($out, $err) = ('') x 2;
    my @opts = @$arg;
    ok(runcheck([[$^X, '-S', 'test-script', @opts],
                 '<', \undef, '>', \$out, '2>', \$err],
                                          sprintf("arg linkage (b) (%s)", 
                                                  join(',', @opts)),
                \$err,
                3),
       1,                                 sprintf("arg linkage (b) (%s) (%2d)",
                                                  join(',', @opts), $i++));
    ok($out, ($j ? sprintf("BOB: %s\n", (qw(1 1 0 0 1))[$j-1]) : ''),
                                          sprintf("arg linkage (b) (%s) (%2d)",
                                                  join(',', @opts), $i++));
    ok($err, (@opts ? "At least one arg must be given\n" : 
                      "Mandatory options missing: bob|b\n"),
                                          sprintf("arg linkage (b) (%s) (%2d)",
                                                  join(',', @opts), $i++));
    $j++;
  }
}
# ----------------------------------------------------------------------------
