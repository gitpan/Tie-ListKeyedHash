#!/usr/bin/perl -w
# $RCSfile: Tie::ListKeyedHash.pm,v $ $Revision: 1.1 $ $Date: 1999/04/29 03:52:36 $ $Author: snowhare $
package Tie::ListKeyedHash;

#######################################################################
#                                                                     #
# The most current release can always be found at                     #
# <URL:http://www.nihongo.org/snowhare/utilities/>                    #
#                                                                     #
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS         #
# OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE           #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A             #
# PARTICULAR PURPOSE.                                                 #
#                                                                     #
# Use of this software in any way or in any form, source or binary,   #
# is not allowed in any country which prohibits disclaimers of any    #
# implied warranties of merchantability or fitness for a particular   #
# purpose or any disclaimers of a similar nature.                     #
#                                                                     #
# IN NO EVENT SHALL I BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,    #
# SPECIAL, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE   #
# USE OF THIS SOFTWARE AND ITS DOCUMENTATION (INCLUDING, BUT NOT      #
# LIMITED TO, LOST PROFITS) EVEN IF I HAVE BEEN ADVISED OF THE        #
# POSSIBILITY OF SUCH DAMAGE                                          #
#                                                                     #
# This program is free software; you can redistribute it              #
# and/or modify it under the same terms as Perl itself.               #
#                                                                     #
# Copyright 1999 Benjamin Franz. All Rights Reserved.                 #
#                                                                     #
#######################################################################

use strict;
use Carp;
use Tie::Hash;
use vars qw ($VERSION @ISA);

$VERSION       = "0.41";
@ISA           = qw (Tie::Hash);

my $func_table = {};

=head1 NAME

Tie::ListKeyedHash - A system allowing the use of anonymous arrays as keys to a hash.

=head1 SYNOPSIS

   use Tie::ListKeyedHash;

   [$X =] tie %hash,  'Tie::ListKeyedHash';


   $hash{['key','items','live']} = 'Hello!';
   $hash{['key','trees','grow']} = 'Goodbye!';
    
   print $hash{['key','items','live']},"\n";
   my (@list) =  keys %{$hash{['key']}};
   print "@list\n";

   untie %hash ;

   Alternatively keys are accessible as:

   $hash{'key','items','live'} = 'Hello!';

   This way slows down the accesses by around 10% and cannot
   be used for keys that conflict with the value of '$;'.

   Also usable via the object interface methods 'put',
   'get','exists','delete','clear'. The object interface
   is about 2x as fast as the tied interface.

=head1 DESCRIPTION

Tie::ListKeyedHash ties a hash so that you can use a reference to an
array as the key of the hash.

=cut

=head1 CHANGES

=head2 0.41 09 Jun 1999

Minor documentation changes.

=head2 0.40 04 May 1999

Yet Another Rename to Tie::ListKeyedHash. Final rename, I promise.

=head2 0.30 04 May 1999

Renamed to 'Tie::ListKeyedHash' after discussion on
comp.lang.perl.module and added (on the suggestion of 
Ilya Zakharevich, <ilya@math.ohio-state.edu>) support 
for using the tie hash as $hash{'key1','key2','key3'}
as well as its native mode of $hash{['key1','key2','key3']}

=head2 0.20 30 April 1999 

Initial public release as 'Tie::ArrayHash' 

=cut

###############################################################################

=head1 METHODS

=over 4

=item C<new(....);>

Returns the object reference for the tie.

=back

=cut

sub new {
    my $something = shift;
    my ($class)   = ref ($something) || $something;
    my $self      = bless {},$class;

	$self;
}

###############################################################################

=over 4

=item C<TIEHASH(....);>

Returns the object reference for the tie.

=back

=cut

sub TIEHASH {
    my $something = shift;
    my ($class)   = ref ($something) || $something;
    my $self      = bless {},$class;

	$self;
}

#######################################################################

=over 4

=item C<STORE($key_ref,$value);>

Stores the $value into the arrayhash location pointed to by the
$key_ref array reference.

If the '$key_ref' is a $; seperated text string instead
of an array reference, it splits it on $; and uses the
resulting array as the actual key.

=back

=cut

sub STORE {
    my $self = shift;

	my ($key,$value) = @_;
	if (not ref $key) {
		$key = [split(/$;/,$key)];
	}
    $self->put($key,$value);
}

#######################################################################

=over 4

=item C<FETCH($key_ref);>

Returns the value pointed to by the $key_ref array reference.

If the '$key_ref' is a $; seperated text string instead
of an array reference, it splits it on $; and uses the
resulting array as the actual key.

=back

=cut

sub FETCH {
    my $self = shift;

	my ($key) = @_;
	if (not ref $key) {
		$key = [split(/$;/,$key)];
	}
	$self->get($key);
}

#######################################################################

=over 4

=item C<DELETE($key_ref);>

Deletes a specified item from the arrayhash.

If the '$key_ref' is a $; seperated text string instead
of an array reference, it splits it on $; and uses the
resulting array as the actual key.

=back

=cut

sub DELETE {
    my $self = shift;
	
	my ($key) = @_;
	if (not ref $key) {
		$key = [split(/$;/,$key)];
	}
    $self->delete($key);
}

#######################################################################

=over 4

=item C<CLEAR;>

Clears the entire arrayhash.

=back

=cut

sub CLEAR {
    my $self = shift;

	$self->clear;
}

#######################################################################

=over 4

=item C<EXISTS($key_ref);>

Returns true if the specified arrayhash key exists, false if it
does not.

If the '$key_ref' is a $; seperated text string instead
of an array reference, it splits it on $; and uses the
resulting array as the actual key.

=back

=cut

sub EXISTS {
    my $self = shift;

	my ($key) = @_;
	if (not ref $key) {
		$key = [split(/$;/,$key)];
	}

	$self->exists($key);
}


#######################################################################

=over 4

=item C<FIRSTKEY;>

Returns the first key.

=back

=cut

sub FIRSTKEY {
    my $self = shift;
	
	my $a = keys %{$self}; # Resets the 'each' to the start
	my $key = scalar each %{$self};
	return if (not defined $key);
	[$key];
}

#######################################################################

=over 4

=item C<NEXTKEY;>

Returns the next key.

=back

=cut

sub NEXTKEY {
    my $self = shift;

	my ($last_key) = @_;
	my $key = scalar each %{$self};
	return if (not defined $key);
	[$key];
}

#######################################################################

=over 4

=item C<DESTROY;>

=back

=cut

sub DESTROY {
    my $self = shift;

}

#######################################################################

=over 4

=item C<clear;>

Clears the entire hash.

=back

=cut

sub clear {
	my ($self) = shift;

	%$self = ();
}

#######################################################################

=over 4

=item C<exists([@key_list]);>

Returns true of the specified hash element exists, false if it does not.
Just as with normal hashes, intermediate elements will be created if
they do not already exist.

The strange elsif construct provides a performance boost for shallow
keys.

=back

=cut

sub exists {
    my ($self) = shift;

	my ($data_ref) = @_;

    my (@data) = @$data_ref;

    my ($result);

	{
		# Its _OK_ if the hash element doesn't exist
        local $^W = undef;

        if ($#data == -1) {
            $result = $self;
        } elsif ($#data == 0) { 
            $result = $$self{$data[0]};
        } elsif ($#data == 1) { 
            $result = $$self{$data[0]}{$data[1]};
        } elsif ($#data > 12) {
            my ($anon_sub);
            if (not defined ($anon_sub = $func_table->{-func_index}->{-get}->[$#data])) {
                my ($lookup) = '$$self';
                my ($count);
                for ($count=0;$count<=$#data;$count++) {
                    $lookup .= '{$$dataref[' . $count . ']}';
                }
                $lookup =<<"EOF";
sub {
    my (\$self,\$dataref) = \@_;
    return (exists $lookup);
};
EOF
                $anon_sub = eval ($lookup);
                $func_table->{-func_index}->{-get}->[$#data] = $anon_sub;
            }
            $result = $self->$anon_sub(\@data);
        } elsif ($#data == 2) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]};
        } elsif ($#data == 3) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]};
        } elsif ($#data == 4) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]};
        } elsif ($#data == 5) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]};
        } elsif ($#data == 6) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]};
        } elsif ($#data == 7) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]};
        } elsif ($#data == 8) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]};
        } elsif ($#data == 9) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]};
        } elsif ($#data == 10) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]};
        } elsif ($#data == 11) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]};
        } elsif ($#data == 12) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]}{$data[12]};
        }
    }

    if (! defined ($result)) {
        return ();
    } else {
		return $result;
	}
}

#######################################################################

=over 4

=item C<get([@key_list]);>

Returns the contents of the object field denoted by the @key_list.
This is a way of making arbitrary keys that act like hashes, with
the 'hardwiring' requirements of hashes. The routine returns the
the contents addressed by 'key1','key2','key3',...

The strange elsif construct provides a performance boost for shallow
keys.

=back

=cut

sub get {
    my ($self) = shift;

	my ($data_ref) = @_;

    my (@data) = @$data_ref;

    my ($result);

	{
		# Its _OK_ if the hash element doesn't exist
        local $^W = undef;

        if ($#data == -1) {
            $result = $self;
        } elsif ($#data == 0) { 
            $result = $$self{$data[0]};
        } elsif ($#data == 1) { 
            $result = $$self{$data[0]}{$data[1]};
        } elsif ($#data > 12) {
            my ($anon_sub);
            if (not defined ($anon_sub = $func_table->{-func_index}->{-get}->[$#data])) {
                my ($lookup) = '$$self';
                my ($count);
                for ($count=0;$count<=$#data;$count++) {
                    $lookup .= '{$$dataref[' . $count . ']}';
                }
                $lookup =<<"EOF";
sub {
    my (\$self,\$dataref) = \@_;
    return ($lookup);
};
EOF
                $anon_sub = eval ($lookup);
                $func_table->{-func_index}->{-get}->[$#data] = $anon_sub;
            }
            $result = $self->$anon_sub(\@data);
        } elsif ($#data == 2) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]};
        } elsif ($#data == 3) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]};
        } elsif ($#data == 4) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]};
        } elsif ($#data == 5) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]};
        } elsif ($#data == 6) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]};
        } elsif ($#data == 7) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]};
        } elsif ($#data == 8) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]};
        } elsif ($#data == 9) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]};
        } elsif ($#data == 10) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]};
        } elsif ($#data == 11) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]};
        } elsif ($#data == 12) { 
            $result = $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]}{$data[12]};
        }
    }

    if (! defined ($result)) {
        return ();
    } else {
		return $result;
	}
}

#######################################################################

=over 4

=item C<put([@key_list],$value);>;

Sets $value as the contents of the object field denoted by the @key_list.
This is a way of making arbitrary keys that act like hashes, without
the 'hardwiring' requirements of hashes.

The strange elsif construct provides a performance boost for shallow
keys.

=back

=cut

sub put {
    my ($self) = shift;

	my ($data_ref,$value) = @_;

    my (@data)  = @$data_ref;

    if ($#data == -1) {
        confess ("Tie::ListKeyedHash::put called without a valid key.\n");
    } elsif (not defined($value)) {
        confess ("Tie::ListKeyedHash::put called without a value to set.\n");
    } elsif ($#data == 0) {
        $$self{$data[0]} = $value;
    } elsif ($#data == 1) {
        $$self{$data[0]}{$data[1]} = $value;
    } elsif ($#data > 12) {
	    my ($anon_sub);
	    if (not defined ($anon_sub = $func_table->{-func_index}->{-put}->[$#data])) {
	    	my ($lookup) = '$$self';
	        my ($count);
	        for ($count=0;$count<=$#data;$count++) {
	            $lookup .=  '{$$dataref[' . $count . ']}';
	        }
        $lookup =<<"EOF";
sub {
    my (\$self,\$dataref,\$valueref) = \@_;
    $lookup = \$valueref;
};
EOF
			$anon_sub = eval ($lookup);
			$func_table->{-func_index}->{-put}->[$#data] = $anon_sub;
	    }
		$self->$anon_sub(\@data,$value);
    } elsif ($#data == 2) {
        $$self{$data[0]}{$data[1]}{$data[2]} = $value;
    } elsif ($#data == 3) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]} = $value;
    } elsif ($#data == 4) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]} = $value;
    } elsif ($#data == 5) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]} = $value;
    } elsif ($#data == 6) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]} = $value;
    } elsif ($#data == 7) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]} = $value;
    } elsif ($#data == 8) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]} = $value;
    } elsif ($#data == 9) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]} = $value;
    } elsif ($#data == 10) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]} = $value;
    } elsif ($#data == 11) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]} = $value;
    } elsif ($#data == 12) {
        $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]}{$data[12]} = $value;
    }
}

#######################################################################

=over 4

=item C<delete([@key_list]);>;

Deletes the object field denoted by the @key_list.

This is a way of making arbitrary keys that act like hashes, without
the 'hardwiring' requirements of hashes.

The strange elsif construct provides a performance boost for shallow
keys.

=back

=cut

sub delete {
    my ($self) = shift;

	my ($data_ref) = @_;

    my (@data) = @$data_ref;

    if ($#data < 0) { # no parms means clear EVERYTHING
        confess ("Tie::ListKeyedHash::_delete object field called with no fields specified.\n",);
    } elsif ($#data == 0) {
        delete $$self{$data[0]};
    } elsif ($#data == 1) { 
        delete $$self{$data[0]}{$data[1]};
    } elsif ($#data > 12) {
    	my ($anon_sub);
		if (not defined ($anon_sub = $func_table->{-func_index}->{-clear}->[$#data])) {
			my ($lookup) = '$$self';
			my ($count);
			for ($count=0;$count<=$#data;$count++) {
				$lookup .= '{$$dataref[' . $count . ']}';
			}
			$lookup =<<"EOF";
sub {
    my (\$self,\$dataref) = \@_;
    delete $lookup;
};
EOF
	        $anon_sub = eval ($lookup);
	        $func_table->{-func_index}->{-clear}->[$#data] = $anon_sub;
	    }
		$self->$anon_sub(\@data);
    } elsif ($#data == 2) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]};
    } elsif ($#data == 3) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]};
    } elsif ($#data == 4) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]};
    } elsif ($#data == 5) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]};
    } elsif ($#data == 6) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]};
    } elsif ($#data == 7) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]};
    } elsif ($#data == 8) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]};
    } elsif ($#data == 9) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]};
    } elsif ($#data == 10) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]};
    } elsif ($#data == 11) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]};
    } elsif ($#data == 12) { 
        delete $$self{$data[0]}{$data[1]}{$data[2]}{$data[3]}{$data[4]}{$data[5]}{$data[6]}{$data[7]}{$data[8]}{$data[9]}{$data[10]}{$data[11]}{$data[12]};
	}
}

=head1 BUGS

To Be Determined.

=head1 TODO

FIRSTKEY, NEXTKEY have to be tested completely.

=head1 AUTHORS 

Benjamin Franz <snowhare@nihongo.org>

=head1 VERSION

Version 0.40 May 1999

Copyright (c) Benjamin Franz 1999. All rights reserved.

 This program is free software; you can redistribute it
 and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl perltie

=cut

1;
