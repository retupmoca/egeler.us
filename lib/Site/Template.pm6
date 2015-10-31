use Config;
use HTML::Template;

unit class Site::Template;

has $.file;

multi method render(*%params) {
    self.render(%params);
}

multi method render(%params) {
    my $base = Config.get('template-base');
    my $template = HTML::Template.from_file($base ~ '/' ~ $.file);
    $template.with_params(%params);
    return $template.output;
}
