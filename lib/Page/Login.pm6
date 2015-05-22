use HTMLPage;
use Page::Redirect;

use Auth::PAM::Simple;

class Page::Login does HTMLPage;

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        if authenticate('login', $request.params<user>, $request.params<password>) {
            $session.data<local-login> = $request.params<user>;
            my $return = $request.params<return>;
            return Page::Redirect.new(:code(302), :url($return || '/'));
        }
    }

    my %data;
    %data<return> = $request.params<return>;
    self.bless(:html-template('login.tmpl'), :%data);
}
