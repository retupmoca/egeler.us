use HTMLPage;

unit class Page::NotFound does HTMLPage;

method html-template { '404.html' }
method html-status { 404 }
