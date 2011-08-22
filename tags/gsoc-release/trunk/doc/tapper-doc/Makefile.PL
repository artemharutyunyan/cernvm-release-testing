use strict;
use warnings;

use inc::Module::Install;

name     'Tapper-Doc';
all_from 'lib/Tapper/Doc.pm';
author   'AMD OSRC Tapper Team <tapper@amd64.org>';
license  'freebsd';

build_requires 'Test::More';

author_requires 'Module::Install::WriteAll';

auto_install;

repository 'git://github.com/amd/Tapper-Doc.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tapper-Doc';

WriteAll;

