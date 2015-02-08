use Test::Most;
use Shell::Carapace;
use Path::Tiny;

my $logfile = path('t/boop.log');
my $shell   = Shell::Carapace->new(logfile => $logfile);

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

$logfile->remove();

done_testing;
