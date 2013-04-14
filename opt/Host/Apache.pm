package Host::Apache;

use strict;
use File::Path qw(make_path remove_tree);
use Shell::Command;
use Host;
our @ISA = qw( Host );

sub new {
    my ( $class, $params ) = @_;
    my $self = $class->SUPER::new( $params );
    $self->{dir_available} = "/etc/apache2/sites-available/";
    $self->{dir_enabled}   = "/etc/apache2/sites-enabled/";
    return $self;
}

#exec apache commands
sub do {
    my $self = shift;
    @_ = grep { /^(start|stop|reload)$/ } @_;
    $_ = (@_)? `/etc/init.d/apache2 $_[0] 2>&1` : '';
    $self->error_set( $_ );
    return ( /\.{3}done\./ )? 1 : 0;
}

#reload apache server
sub reload {
    return $_[0]->do('reload');
}

sub add {
    my ( $self, $params ) = @_;
    foreach ( 'domain', 'user', 'subdomain' ) {
        $self->{$_} = ($params->{$_})? $params->{$_} : '';
    }
    die( $self->error ) if !$self->check_option( ['domain', 'user'] )
                           || ( $self->{subdomain} && !$self->check_option( ['subdomain'] ) );

    my $apache_domain = $self->{dir_available}.'/'.$self->{domain};
    make_path( $apache_domain );
    
    $self->publish( 'apache/domain.default', $apache_domain.'/'.$self->{domain} );
    symlink( $apache_domain, $self->{dir_enabled}.'/'.$self->{domain} );

    my $d_home = "/home/".$self->{user}."/".$self->{domain};
    my $d_log = "$d_home/log/apache2";    

    make_path( "$d_home/www/cgi-bin", $d_log );
    touch( "$d_log/access.log", "$d_log/error.log" );

    if( $self->{subdomain} ) {
        $self->publish( 'apache/subdomain.default', $apache_domain.'/'.$self->{subdomain}.'.'.$self->{domain} );
        my $sd_home = "$d_home/".$self->{subdomain};
        my $sd_log = "$sd_home/log";
        make_path( "$sd_home/www/cgi-bin", "$sd_log/apache2" );
        touch( "$sd_log/apache2/access.log", "$sd_log/apache2/error.log" );
        symlink "$sd_log/apache2", "$d_log/".$self->{subdomain};
    }

    $self->dir_owner( $d_home, $self->{user} );
    $self->reload;
}


1;
