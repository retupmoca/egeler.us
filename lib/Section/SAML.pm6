unit class Section::SAML;

use Section::SAML::Meta;
use Section::SAML::Auth;
use Section::SAML::AuthRespond;

method router {
    my $router = Path::Router.new;
    $router.add-route('metadata', target => Section::SAML::Meta);
    $router.add-route('auth', target => Section::SAML::Auth);
    $router.add-route('authrespond', target => Section::SAML::AuthRespond);
    return $router;
}
