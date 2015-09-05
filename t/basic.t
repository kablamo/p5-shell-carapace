use Test::Most;
use Shell::Carapace;

my $basic_test = sub {
    my ($cat, $msg) = @_;

    is $msg, "hi there", $cat       if $cat eq 'local-output';
    is $msg, "echo hi there", $cat  if $cat eq 'command';
    fail "should not have an error" if $cat eq 'error';
};

my $shell = Shell::Carapace->new(callback => $basic_test);

subtest 'list' => sub {
    $shell->callback($basic_test);
    $shell->local(qw/echo hi there/);
};

subtest 'string' => sub {
    $shell->callback($basic_test);
    $shell->local('echo hi there');
};

subtest 'dies ok' => sub {
    my $test = sub {
        my ($cat, $msg) = @_;
        pass "error" if $cat eq 'error';
    };
    $shell->callback($test);
    dies_ok { $shell->local(qw/ls sdflk823jfsk3adffsupercalifragilistic/) } 'dead';
};

done_testing;
