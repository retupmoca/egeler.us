use Site::Template;
use Page::Redirect;

use Auth::PAM::Simple;

unit class Page::Login;

method handle(:$request, :$session) {
    my $params = $request.parameters;
    if $request.method eq 'POST' {
        if authenticate('login', $params<user>, $params<password>) {
            $session.data<local-login> = $params<user>;
            my $return = $params<return>;
            return Page::Redirect.new(:code(302), :url($return || '/'))
                                 .handle(:$request, :$session);
        }
    }

    return [ 200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('login.tmpl'))
                            .render(return => $params<return>) ]];
}
