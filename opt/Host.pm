package Host;

use strict;

use File::Find qw(finddepth);
use Shell::Command;
use Template;

sub new {
    my ( $class, $params ) = @_;
    my $self = {};

    $self->{error} = '';
    $self->{template} = Template->new( { INCLUDE_PATH => 'conf/' } );
    
    bless $self, ref $class || $class;

    $self->set_user_params;

    return $self;
}

#return error message
sub error {
    my $self = shift;
    return $self->{error};
}

#set error message
sub error_set {
    my $self = shift;
    $self->{error} = (@_)? join "\n", @_ : '';
    return 1;
}

#reset error message
sub error_reset {
    my $self = shift;
    return $self->error_set;
}

#add error message
sub error_push {
    my $self = shift;
    $self->{error} .= "\n" if $self->{error};
    $self->{error} = $self->{error}.(join "\n", @_);
    return 1;
}

#return user's params: name, password, user ID, group ID
sub check_user {
    my ( $self, $user ) = @_;
    $user ||= $ENV{"LOGNAME"};
    my @result = getpwnam( $user );
    return (@result)? @result : 0;
}
#set user's params: name, password, user ID, group ID
#if empty params, set current system user's params
#return 0 if any error. text of the error is in $self->error
# $host->set_user_params( 'root' );  #set params of root user
# $host->set_user_params;            #set params of current user
sub set_user_params {
    my ( $self, $user ) = @_;
    $user ||= '';
    ( $self->{login}, $self->{pass}, $self->{uid}, $self->{gid} ) = check_user( $user );
    if ( $self->{login} ) {
        return 1;
    } else {
        $self->error_set("User $user not found");
        return 0;
    }
}

#change owner of directory recursively
#return 0 if any error. text of the error is in $self->error
# $host->dir_owner( '/var/www/', 'root' );   #set /var/www directory's owner to root
# $host->dir_owner( '/path/to/dir' );       #set /path/to/dir directory's owner to current user
sub dir_owner {
    my ( $self, $dir, $user ) = @_;
    return 0 unless $self->set_user_params( $user );
    unless ( -e $dir ) {
        $self->error_set("Directory $dir not found");
        return 0;
    }
    chown $self->{uid}, $self->{gid}, $dir;
    finddepth( sub { chown $self->{uid}, $self->{gid}, $File::Find::name unless /^\.+$/; }, $dir );
    $self->set_user_params;
    return 1;
}

#check options
#parameters are: 
#return 0 if any error. text of the error is in $self->error
sub check_option {
    my ($self, $options) = @_;
    $self->error_reset;
    foreach ( @$options ) {
        if( !$self->{$_} ) {
            $self->error_push("$_ name missing");
            next;
        }

        if( /^domain$/ && $self->{$_}!~/^[a-z0-9][a-z0-9-.]+$/i ) {
            $self->error_push("Domain name $self->{$_} contains wrong chars");
        }

        if( /^subdomain$/ && $self->{$_}!~/^[a-z0-9][a-z0-9-]+$/i ) {
            $self->error_push("Subomain name $self->{$_} contains wrong chars");
        }

        if( /^user$/ ) {
            if( $self->{$_} !~ /^[\w.-]+$/ ) {
                $self->error_push("User name contains wrong chars");
            } elsif( !$self->check_user( $self->{$_} ) ) {
                $self->error_push("User $self->{$_} don't exists");
            }
        }
    }
    return ( $self->error )? 0 : 1;
}

#publish file $file from $template template with parameters $options
#default parameters are: domain, subdomain, user
# $self->publish( 'apache/domain.default', '/etc/apache2/sites-available/example.com' );
sub publish {
    my ( $self, $template, $file, $options ) = @_;
    $options ||= {};
    $options = { %$options, domain => $self->{domain}, subdomain => $self->{subdomain}, user => $self->{user} };
    my $result = $self->{template}->process( $template, $options, $file );
    $self->error_set( $self->{template}->error() ) unless $result;
    return $result;
}
1;

