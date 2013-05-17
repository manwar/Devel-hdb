package Devel::hdb::App::SourceFile;

use strict;
use warnings;

use base 'Devel::hdb::App::Base';

__PACKAGE__->add_route('get', '/sourcefile', \&sourcefile);

# send back a list.  Each list elt is a list of 2 elements:
# 0: the line of code
# 1: whether that line is breakable
sub sourcefile {
    my($class, $app, $env) = @_;

    my $req = Plack::Request->new($env);
    my $resp = $app->_resp('sourcefile', $env);

    my $filename = $req->param('f');
    my $file = DB->file_source($filename);

    my @rv;
    if ($file) {
        no warnings 'uninitialized';  # at program termination, the loaded file data can be undef
        #my $offset = $file->[0] =~ m/use\s+Devel::_?hdb;/ ? 1 : 0;
        my $offset = 1;

        for (my $i = $offset; $i < scalar(@$file); $i++) {
            no warnings 'numeric';  # eval-ed "sources" generate "not-numeric" warnings
            push @rv, [ $file->[$i], $file->[$i] + 0 ];
        }
    }

    $resp->data({ filename => $filename, lines => \@rv});

    return [ 200,
            [ 'Content-Type' => 'application/json' ],
            [ $resp->encode() ]
        ];
}


1;

=pod

=head1 NAME

Devel::hdb::App::SourceFile - Get Perl source for the running program

=head1 DESCRIPTION

Registers a route used to get the Perl source code for files used by the
debugged program.

=head2 Routes

=over 4

=item /sourcefile

This route requires one parameter 'f' , the filename to get the source for.
It returns a JSON-encoded array of arrays.  The first-level array has one
element for each line in the file.  The second-level elements each have
2 elements.  The first is the Perl source for that line in the file.  The
second element is 0 if the line is not breakable, and true if it is.

=back

=head1 SEE ALSO

Devel::hdb

=head1 AUTHOR

Anthony Brummett <brummett@cpan.org>

=head1 COPYRIGHT

Copyright 2013, Anthony Brummett.  This module is free software. It may
be used, redistributed and/or modified under the same terms as Perl itself.
