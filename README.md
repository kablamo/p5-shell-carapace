[![Build Status](https://travis-ci.org/kablamo/p5-shell-carapace.svg?branch=master)](https://travis-ci.org/kablamo/p5-shell-carapace) [![Coverage Status](https://img.shields.io/coveralls/kablamo/p5-shell-carapace/master.svg)](https://coveralls.io/r/kablamo/p5-shell-carapace?branch=master)
# NAME

Shell::Carapace - cpanm style logging for shell commands

# SYNOPSIS

    use Shell::Carapace;

    my $shell = Shell::Carapace->new(
        verbose => 1,                   # tee shell cmd output to STDOUT/STDERR
        logfile => '/path/to/file.log', # output is always written to this file
    );

    my $output = $shell->local(@cmd);
    my $output = $shell->remote($user, $host, @cmd);

    # Useful for testing:
    # The noop attr tells local() to not run the shell cmd
    # Instead local() will return the cmd as a quote sring
    $shell->noop(1);
    my $cmd = $shell->local(@cmd);

# DESCRIPTION

cpanm does a great job of not printing unnecessary output to the screen.  But
sometimes you need verbose output in order to debug problems.  To solve this
problem cpanm logs at a verbose level to a logfile.

This module provides infrastructure so developers can easily add similar
functionality to their command line applications.

Shell::Carapace is mostly a very small wrapper around Capture::Tiny.

# ERROR HANDLING

local() and remote() both die if a command fails by returning a positive exit
code. 

# SEE ALSO

- Shell::Cmd
- Capture::Tiny::Extended
- Net::OpenSSH
- Capture::Tiny
- IPC::System::Simple

# About the name

Carapace: n. A protective, shell-like covering likened to that of a turtle or crustacean

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Eric Johnson <eric.git@iijo.org>
