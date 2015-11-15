package Shell::Carapace::SSH;
use Moo;

use Net::OpenSSH;
use String::ShellQuote;
use Carp;

has callback    => (is => 'rw', required => 1);
has host        => (is => 'rw', required => 1);
has ssh_options => (is => 'rw', lazy => 1, default => sub { {} });
has ssh         => (is => 'rw', lazy => 1, builder => 1);

sub _build_ssh {
    my $self = shift;
    require Net::OpenSSH;
    return Net::OpenSSH->new($self->host, %{ $self->ssh_options });
}

sub run {
    my ($self, @cmd) = @_;

    $self->callback->('command', $self->_stringify(@cmd), $self->host);

    my ($pty, $pid) = $self->ssh->open2pty(@cmd);

    while (my $line = <$pty>) {
      $line =~ s/([\r\n])$//g;
      $self->callback->('remote-output', $line, $self->host);
    }   

    waitpid($pid, 0);

    if ($? != 0) {
        $self->callback->("error", undef, $self->host);
        croak "cmd failed";
    }
}

sub _stringify {
    my ($self, @cmd) = @_;
    return $cmd[0] if @cmd == 1;
    return join(" ", shell_quote @cmd);
}

1;
