package fc_databases;

our $VERSION = '0.01';
our @ISA     = qw( Exporter );
our @EXPORT  = qw( 
		   connect sql disconnect
		);

use strict;
use DBI;

our $dbh;
my $r;

my $type = "mysql";
my $login = 'fp_exli_net';
my $password = 'fp_exli_net';
my $dbname = 'fp_exli_net';
my $host = 'localhost';
my $port = 3306;

=sub connect
 connect to the database
=cut
sub connect {
    $dbh = DBI->connect("dbi:$type:dbname=$dbname;host=$host;port=$port", $login, $password, {PrintError => 1});
}

=sub disconnect
 disconnect from the database
=cut
sub disconnect {
    $dbh->disconnect;
}

=sub sql
 exwcute sql
=cut
sub sql {
  my $query = shift;
  my @params = @_;
  my @result;

  eval {
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(@params);

    if($sth->{NUM_OF_FIELDS}) {    
	while(my ($r) = $sth->fetchrow_hashref()) {
	    last unless defined($r);
	    push @result, $r;
	}
    }
    
    $sth->finish();
  };

  if ($@) {
    return 0;
  } else {
    return \@result;
  }

}

1;

