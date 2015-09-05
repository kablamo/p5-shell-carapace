package Shell::Carapace;
use Moo;

use IPC::Open3::Simple;
use String::ShellQuote;
use Carp;
use Time::Piece;

our $VERSION = "0.11";

=head1 NAME

Shell::Carapace - Simple realtime output for ssh and shell commands

=head1 SYNOPSIS

    use Shell::Carapace;

    my $shell = Shell::Carapace->new(
        host        => $hostname,    # for Net::OpenSSH
        ssh_options => $ssh_options, # hash for Net::OpenSSH
        callback    => sub {         # require.  handles cmd output, errors, etc
            my ($category, $message) = @_;
            print "  $message\n"        if $category =~ /output/ && $message;
            print "Running $message\n"  if $category eq 'command';
            print "ERROR: cmd failed\n" if $category eq 'error';
        },
    );

    # these commands throw an exception if @cmd fails
    $shell->local(@cmd);
    $shell->remote(@cmd);

=head1 DESCRIPTION

Shell::Carapace is a small wrapper around Log::Any, IPC::Open3::Simple,
Net::OpenSSH.  It provides a callback so you can easily log or process cmd output
in realtime.  Ever run a script that takes 30 minutes to run and have to wait
30 minutes to see the output?  This module solve that problem.

=head1 METHODS

=head2 new()

All parameters are optional except 'callback'.  The following parameters are accepted:

   callback    : Required.  A coderef which is executed in realtime as output
                 is emitted from the command.
   host        : A string like 'localhost' or 'user@hostname' which is passed
                 to Net::OpenSSH.  Net::OpenSSH defaults the username to the
                 current user.  Optional unless using ssh.
   ssh_options : A hash which is passed to Net::OpenSSH.
   ipc         : An IPC::Open3::Simple object.  You probably don't need this.
   ssh         : A Net::OpenSSH object.  You probably don't need this.

=head2 local(@cmd)

Execute the command locally via IPC::Open3::Simple.  Calls the callback in
realtime for each line of output emitted from the command.

=head3 remote(@cmd)

Execute the command on a remote host via Net::OpenSSH.  Calls the callback in
realtime for each line of output emitted from the command.

=cut

has callback    => (is => 'rw', required => 1);
has ipc         => (is => 'rw', lazy => 1, builder => 1);
has ssh         => (is => 'rw', lazy => 1, builder => 1);
has host        => (is => 'rw', lazy => 1, default => sub { die "host param is required for ssh" });
has ssh_options => (is => 'rw', lazy => 1, default => sub { {} });

sub _build_ipc {
    my $self = shift;
    require IPC::Open3::Simple;
    return  IPC::Open3::Simple->new(
        out => sub { $self->callback->('local-output', $_[0]) },
        err => sub { $self->callback->('local-output', $_[0]) },
    ); 
}

sub _build_ssh {
    my $self = shift;
    require Net::OpenSSH;
    return Net::OpenSSH->new($self->host, %{ $self->ssh_options });
}

sub local {
    my ($self, @cmd) = @_;

    $self->callback->('command', $self->_stringify(@cmd));

    $self->ipc->run(@cmd);

    if ($? != 0) {
        $self->callback->("error");
        croak "cmd failed";
    }
};

sub remote {
    my ($self, @cmd) = @_;

    $self->callback->('command', $self->_stringify(@cmd));

    my ($pty, $pid) = $self->ssh->open2pty(@cmd);

    while (my $line = <$pty>) {
      $line =~ s/([\r\n])$//g;
      $self->callback->('remote-output', $line);
    }   

    waitpid($pid, 0);

    if ($? != 0) {
        $self->callback->("error");
        croak "cmd failed";
    }
}

sub _stringify {
    my ($self, @cmd) = @_;
    return $cmd[0] if @cmd == 1;
    return join(" ", shell_quote @cmd);
}

1;

=head1 ABOUT THE NAME

Carapace: n. A protective, shell-like covering likened to that of a turtle or crustacean

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Eric Johnson E<lt>eric.git@iijo.orgE<gt>

=cut

