requires 'Moo';
requires 'Capture::Tiny';
requires 'Types::Path::Tiny';
requires 'Path::Tiny';

on 'test' => sub {
    requires 'Test::Most';
};

