# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

class nginx  {

    package { nginx: ensure => installed }

    file { "/usr/local/bin/fcgi-wrapcgi.pl":
        source => "puppet:///nginx/fcgi-wrapcgi.pl",
        mode => 755,
        owner => root,
        before => Service[nginx]
    }

    file { "/etc/nginx/nginx.conf":
        content => template("nginx/nginx.conf.erb"),
        mode => 644,
        owner => root,
        notify => Service[nginx]
    }

    file { "/etc/nginx/sites-enabled/default":
        ensure => absent,
        notify => Service[nginx]
    }
    
    #can just subscribe to a directory, or would this miss changes?
    service { nginx:
        ensure => running,
        enable => true,
    }

    define site ($server_name="localhost", $doc_root="/var/www", $port=80, $conf_source="nginx/site.conf.erb", $enable_cgi=false) {
        file { "/etc/nginx/sites-available/${name}.conf":
            content => template($conf_source),
            ensure => present,
        }
        file { "/etc/nginx/sites-enabled/${name}.conf":
            ensure => link,
            target => "/etc/nginx/sites-available/${name}.conf",
            notify => Service[nginx]
        }
    }
}


