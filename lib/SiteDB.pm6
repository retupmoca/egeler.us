class SiteDB;
use Config;
use DBIish;
use JSON::Tiny;

role WithQuery {
    method with-query($query, *@rest){
        my &block = @rest.pop;
        my @params = @rest.flat;
        my $sth = self.prepare($query);
        $sth.execute(@params);
        return block($sth);
        LEAVE $sth.finish;
    }
}

sub run-db-script($dbh, $script) {
    my @script-data = $script.IO.slurp.split(/\;\n/);
    for @script-data {
        # use with-query to ensure $sth.finish gets called
        $dbh.with-query: $_, -> $sth { };
    }
}

sub db-update($dbh, $dbname) {
    my $dir = Config.get('database-revision-base') ~ '/' ~ $dbname;
    my @files = $dir.IO.dir;

    # get an index of revisions available
    my $latest;
    my %revs;
    for @files -> $f {
        my @name = $f.basename.split(/\./);
        next unless @name[0] ~~ /^\d+$/;
        next unless @name[*-1] eq 'sql';
        if @name[0] > $latest {
            $latest = @name[0];
        }

        if @name[1] eq 'full' {
            %revs{@name[0]}<f> = $f;
        }
        elsif @name == 2 {
            %revs{@name[0]}<i> = $f;
        }
    }

    my $current;
    try $dbh.with-query: 'SELECT MAX(revnum) as revnum FROM dbrev',
                         { $current = $_.fetchrow-hash<revnum>; };

    if $current > $latest {
        die 'current database revision is from the future';
    }
    elsif !$current {
        # looks like we get to initialize from scratch
        # just import the latest full dump, let below finish it up
        $current = $latest;
        while !%revs{$current}<f> {
            $current--;
        }
        run-db-script($dbh, %revs{$current}<f>);
        $dbh.do("INSERT INTO revnum VALUES(?)", $current);
    }

    while $current < $latest {
        $current++;
        run-db-script($dbh, %revs{$current}<i>);
        $dbh.do("INSERT INTO revnum VALUES(?)", $current);
    }
}

my $config;
my %revchecked;
sub db-connect($dbname) {
    unless $config {
        $config = Config.get('database');
    }
    my $item = $config{$dbname};

    die "Unable to find configuration for database $dbname" unless $item;

    my $dbh = DBIish.connect('mysql',
                   :user($item<user>),
                   :password($item<password>),
                   :host($item<host>),
                   :port('3306'),
                   :database($dbname),
                   RaiseError => 1,
                   PrintError => 1,
                   AutoCommit => 1) but WithQuery;
    
    unless %revchecked{$dbname} {
        db-update($dbh, $dbname);
        %revchecked{$dbname} = 1;
    }
    return $dbh;
}

my @freelist;
method with-database($dbname, &block) {
    my $dbh;
    while !$dbh && @freelist {
        my $tmp = @freelist.pop;
        $dbh = $tmp if $tmp.ping;
    }
    $dbh = db-connect($dbname) unless $dbh;
    return block($dbh);
    LEAVE @freelist.push($dbh);
}
