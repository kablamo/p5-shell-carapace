use Test::Most;# skip_all => 'requires ssh';
use Shell::Carapace;

my $basic_test = sub {
    my ($cat, $msg) = @_;

    is $msg, "hi there", $cat       if $cat eq 'remote-output';
    is $msg, "echo hi there", $cat  if $cat eq 'command';
    fail "should not have an error" if $cat eq 'error';
};

my $ssh = Shell::Carapace->ssh(host => 'localhost', callback => $basic_test);

subtest 'list' => sub {
    $ssh->callback($basic_test);
    $ssh->run(qw/echo hi there/);
};

subtest 'string' => sub {
    $ssh->callback($basic_test);
    $ssh->run('echo hi there');
};

subtest 'dies ok' => sub {
    my $test = sub {
        my ($cat, $msg) = @_;
        pass "error" if $cat eq 'error';
    };
    $ssh->callback($test);
    dies_ok { $ssh->run(qw/ls sdflk823jfsk3adffsupercalifragilistic/) } 'dead';
};

done_testing;