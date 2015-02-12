package Shell::Carapace;
use feature qw/say/;
use Moo;

use Capture::Tiny qw/:all/;
use Types::Standard qw/Maybe/;
use Types::Path::Tiny qw/Path/;
use String::ShellQuote;

our $VERSION = "0.05";

=head1 NAME

Shell::Carapace - cpanm style logging for shell commands

=head1 SYNOPSIS

    use Shell::Carapace;

    my $shell = Shell::Carapace->new(
        verbose => 1,                   # tee shell cmd output to STDOUT/STDERR
        logfile => '/path/to/file.log', # log cmd output
    );

    my $output = $shell->local(@cmd);
    my $output = $shell->remote($user, $host, @cmd);

    # Useful for testing:
    # The noop attr tells local() to not run the shell cmd
    # Instead local() will return the cmd as a quoted string
    $shell->noop(1);
    my $cmd = $shell->local(@cmd);

=head1 DESCRIPTION

cpanm does a great job of not printing unnecessary output to the screen.  But
sometimes you need verbose output in order to debug problems.  To solve this
problem cpanm logs at a verbose level to a logfile.

This module provides infrastructure so developers can easily add similar
functionality to their command line applications.

Shell::Carapace is mostly a very small wrapper around Capture::Tiny.

=head1 ERROR HANDLING

local() and remote() both die if a command fails by returning a positive exit
code. 

=cut

has verbose     => (is => 'rw', default => sub { 0 });
has print_cmd   => (is => 'ro', default => sub { 0 });
has ssh_cmd     => (is => 'lazy', default => sub { '/usr/bin/ssh' });
has ssh_options => (is => 'lazy', default => sub { [] });
has logfile     => (is => 'rw', isa => Maybe[Path], coerce => Path->coercion, clearer => 1);
has noop        => (is => 'rw', default => sub { 0 });

before logfile => sub {
    my ($self, $logfile) = @_;
    
    return unless $logfile;

    die "Logfile is not writeable: $logfile\n"
        unless -w $logfile;

    die "Logfile is not a file: $logfile\n"
        unless -f $logfile;
};

sub remote {
    my ($self, $user, $host, @cmd) = @_;

    my $ssh_opts = $self->ssh_options;
    my @ssh_cmd  = (scalar @cmd == 1)
        ? (join(" ", $self->ssh_cmd, "$user\@$host", @$ssh_opts, @cmd))
        : ($self->ssh_cmd, "$user\@$host", @$ssh_opts, @cmd);

    $self->local(@ssh_cmd);
}

sub local {
    my ($self, @cmd) = @_; 

    say ">> " . join(" ", @cmd) if $self->verbose || $self->print_cmd;

    if ($self->noop) {
        return $cmd[0] if scalar @cmd == 1;
        return join(" ", shell_quote(@cmd));
    }

    my ($merged_out, $exit) = $self->verbose
        ? tee_merged     { system @cmd }
        : capture_merged { system @cmd };

    if ($self->logfile) {
        $self->logfile->touchpath;
        $self->logfile->append_utf8(">> " . join(" ", @cmd) . "\n");
        $self->logfile->append_utf8($merged_out);
    }

    die "\n" if $exit;

    return $merged_out;
}

1;

=head1 SEE ALSO

=over 4

=item Shell::Cmd

=item Capture::Tiny::Extended

=item Net::OpenSSH

=item Capture::Tiny

=item IPC::System::Simple

=back

=head1 About the name

Carapace: n. A protective, shell-like covering likened to that of a turtle or crustacean

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Eric Johnson E<lt>eric.git@iijo.orgE<gt>

=cut

