use Test::Most skip_all => 'requires ssh';
use Shell::Carapace;
use Sys::Hostname;

my $basic_test = sub {
    my ($cat, $msg, $host) = @_;

    is $msg, "hi there", $cat       if $cat eq 'remote-output';
    is $msg, "echo hi there", $cat  if $cat eq 'command';
    is $host, "eric", $cat;
    fail "should not have an error" if $cat eq 'error';
};

my $ssh = Shell::Carapace->ssh(host => 'eric', callback => $basic_test);

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
        my ($cat, $msg, $host) = @_;

        is $host, "eric", $cat;
        is $msg,  "ls sdfljfskfsupercalifragilistic", $cat 
            if $cat eq any(qw/error command/);
    };

    $ssh->callback($test);
    dies_ok { $ssh->run(qw/ls sdfljfskfsupercalifragilistic/) } 'dead';
};

done_testing;
