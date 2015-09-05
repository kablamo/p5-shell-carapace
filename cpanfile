requires 'Moo';
requires 'String::ShellQuote';
requires 'IPC::Open3::Simple';
requires 'Net::OpenSSH';
requires 'IO::Pty';

on 'test' => sub {
    requires 'Test::Most';
};

on 'build' => sub {
    requires 'Minilla';
    requires 'Test::MinimumVersion::Fast';
    requires 'Test::Pod';
}

