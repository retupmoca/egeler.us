class Session {
    has $.seen is rw;
    has $.id;
    has %.data is rw;

    method new(:$id is copy){
        $id = ('a'..'z','A'..'Z','0'..'9').roll(32).join unless $id;
        my %foo;
        self.bless(:$id, :seen(time), :data(%foo));
    }
}

class SessionManager {
    has %!sessions;

    multi method load(Str $id where { $_.chars > 0 }) {
        for %!sessions.kv -> $k, $v {
            if $v.seen < (time - 60*60) {
                %!sessions{$k}:delete;
            }
        }

        my $session = %!sessions{$id};
        return False unless $session;
        $session.seen = time;
        return $session;
    }
    multi method load($id) {
        False;
    }

    method create {
        my $session = Session.new();
        %!sessions{$session.id} = $session;
        return $session;
    }
}
