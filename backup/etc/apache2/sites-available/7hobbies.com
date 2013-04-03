<VirtualHost *:80>

	AssignUserId 7hobbies 7hobbies

        ServerName 7hobbies.com
        ServerAlias *.7hobbies.com
        DocumentRoot /home/7hobbies/www
        ScriptAlias /cgi-bin/ /home/7hobbies/www/cgi-bin

        <Directory />
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                AllowOverride All
                AddHandler cgi-script .cgi .pl
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog /var/log/apache2/users/7hobbies/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/users/7hobbies/access.log combined

</VirtualHost>

