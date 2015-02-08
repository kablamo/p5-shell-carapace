# NAME

Shell::Carapace - cpanm style logging for shell commands

# SYNOPSIS

    use Shell::Carapace;

    my $shell = Shell::Carapace->new(
        verbose => 1, # tee shell output to STDOUT/STDERR
        logfile => '/path/to/file.log',
    );

    my $output = $shell->local(@cmd);
    my $output = $shell->remote($user, $host, @cmd);

    # Useful for testing:
    # The noop attr tells local() to not run the shell cmd
    # Instead local() will return the cmd as a quote sring
    $shell->noop(1);
    my $cmd = $shell->local(@cmd);

# DESCRIPTION

Shell::Carapace makes it easy to add cpanm style logging to your command line
application.  It is a small wrapper around Capture::Tiny which provides logging
and throws exceptions when commands fail.

Cpanm has does a great job of not printing tons of unnecessary output to the
screen.  However you occasionally need verbose output in order to debug
problems.  To solve this problem cpanm also logs at a verbose level to a
logfile.

This module provides infrastructure so developers can easily add similar
functionality to their command line applications.

# ERROR HANDLING

local() and remote() both die if a command fails by returning a positive exit
code. 

# SEE ALSO

- Capture::Tiny::Extended
- Net::OpenSSH

    Net::OpenSSH has better performance because it uses a single ssh connection for
    the life of the object.  Its a mature project with lots of functionality.  

- Capture::Tiny
- IPC::System::Simple

# About the name

Carapace: n. A protective, shell-like covering likened to that of a turtle or crustacean

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Eric Johnson <eric.git@iijo.org>

But most of the code is heavily borrowed from Miyagawa's excellent
App::cpanminus module.
