requires 'Moo';
requires 'Capture::Tiny';
requires 'Types::Path::Tiny';
requires 'Path::Tiny';
requires 'String::ShellQuote';

on 'test' => sub {
    requires 'Test::Most';
};

on 'build' => sub {
    requires 'Minilla';
}

