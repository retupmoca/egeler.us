use Site::Template;
use Page::Redirect;

use Auth::PAM::Simple;

unit class Page::Login;

method handle(:$request, :$session) {
    if $request.method eq 'POST' {
        if authenticate('login', $request.params<user>, $request.params<password>) {
            $session.data<local-login> = $request.params<user>;
            my $return = $request.params<return>;
            return Page::Redirect.new(:code(302), :url($return || '/'))
                                 .handle(:$request, :$session);
        }
    }

    return [ 200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('login.tmpl'))
                            .render(return => $request.params<return>) ]];
}
