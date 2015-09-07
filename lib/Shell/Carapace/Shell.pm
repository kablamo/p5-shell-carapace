package Shell::Carapace::Shell;
use Moo;

use IPC::Open3::Simple;
use String::ShellQuote;
use Carp;

has callback    => (is => 'rw', required => 1);
has ipc         => (is => 'rw', lazy => 1, builder => 1);

sub _build_ipc {
    my $self = shift;
    require IPC::Open3::Simple;
    return  IPC::Open3::Simple->new(
        out => sub { $self->callback->('local-output', $_[0]) },
        err => sub { $self->callback->('local-output', $_[0]) },
    ); 
}

sub run {
    my ($self, @cmd) = @_;

    $self->callback->('command', $self->_stringify(@cmd));

    $self->ipc->run(@cmd);

    if ($? != 0) {
        $self->callback->("error");
        croak "cmd failed";
    }
};

sub _stringify {
    my ($self, @cmd) = @_;
    return $cmd[0] if @cmd == 1;
    return join(" ", shell_quote @cmd);
}

1;