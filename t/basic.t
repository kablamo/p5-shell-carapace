use Test::Most;
use Shell::Carapace;
use Path::Tiny;

my $logfile = path('t/boop.log');
my $shell   = Shell::Carapace->new(logfile => $logfile->stringify);

subtest 'list' => sub {
    $logfile->remove();
    my $output = $shell->local(qw/echo hi there/);
    is $output, "hi there\n", "return value";
    is $logfile->slurp_utf8(), ">> echo hi there\nhi there\n", "log file";
};

subtest 'string' => sub {
    $logfile->remove();
    my $output = $shell->local('echo hi there');
    is $output, "hi there\n", "return value";
    is $logfile->slurp_utf8(), ">> echo hi there\nhi there\n", "log file";
};

subtest 'no logfile' => sub {
    $logfile->remove();
    $shell->clear_logfile();
    my $output = $shell->local(qw/echo hi there/);
    is $output, "hi there\n", "return value";
    ok !$logfile->exists, "did not create a log file";
};

done_testing;
