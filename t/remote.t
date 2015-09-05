use Test::Most skip_all => 'requires ssh';
use Shell::Carapace;

my $basic_test = sub {
    my ($cat, $msg) = @_;

    is $msg, "hi there", $cat       if $cat eq 'remote-output';
    is $msg, "echo hi there", $cat  if $cat eq 'command';
    fail "should not have an error" if $cat eq 'error';
};

my $shell = Shell::Carapace->new(host => 'localhost', callback => $basic_test);

subtest 'list' => sub {
    $shell->callback($basic_test);
    $shell->remote(qw/echo hi there/);
};

subtest 'string' => sub {
    $shell->callback($basic_test);
    $shell->remote('echo hi there');
};

subtest 'dies ok' => sub {
    my $test = sub {
        my ($cat, $msg) = @_;
        pass "error" if $cat eq 'error';
    };
    $shell->callback($test);
    dies_ok { $shell->remote(qw/ls sdflk823jfsk3adffsupercalifragilistic/) } 'dead';
};

done_testing;
