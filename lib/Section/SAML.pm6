use Site::Tools;

unit class Section::SAML is Site::Router;

use Section::SAML::Meta;
use Section::SAML::Auth;
use Section::SAML::AuthRespond;

method routes {
    $.route('metadata',    Section::SAML::Meta);
    $.route('auth',        Section::SAML::Auth);
    $.route('authrespond', Section::SAML::AuthRespond);
}
