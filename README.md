[![Build Status](https://travis-ci.org/kablamo/p5-shell-carapace.svg?branch=master)](https://travis-ci.org/kablamo/p5-shell-carapace) [![Coverage Status](https://img.shields.io/coveralls/kablamo/p5-shell-carapace/master.svg)](https://coveralls.io/r/kablamo/p5-shell-carapace?branch=master)
# NAME

Shell::Carapace - Simple realtime output for ssh and shell commands

# SYNOPSIS

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

# DESCRIPTION

Shell::Carapace is a small wrapper around Log::Any, IPC::Open3::Simple,
Net::OpenSSH.  It provides a callback so you can easily log or process cmd output
in realtime.  Ever run a script that takes 30 minutes to run and have to wait
30 minutes to see the output?  This module solve that problem.

# METHODS

## new()

All parameters are optional except 'callback'.  The following parameters are accepted:

    callback    : Required.  A coderef which is executed in realtime as output
                  is emitted from the command.
    host        : A string like 'localhost' or 'user@hostname' which is passed
                  to Net::OpenSSH.  Net::OpenSSH defaults the username to the
                  current user.  Optional unless using ssh.
    ssh_options : A hash which is passed to Net::OpenSSH.
    ipc         : An IPC::Open3::Simple object.  You probably don't need this.
    ssh         : A Net::OpenSSH object.  You probably don't need this.

## local(@cmd)

Execute the command locally via IPC::Open3::Simple.  Calls the callback in
realtime for each line of output emitted from the command.

### remote(@cmd)

Execute the command on a remote host via Net::OpenSSH.  Calls the callback in
realtime for each line of output emitted from the command.

# ABOUT THE NAME

Carapace: n. A protective, shell-like covering likened to that of a turtle or crustacean

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Eric Johnson <eric.git@iijo.org>
