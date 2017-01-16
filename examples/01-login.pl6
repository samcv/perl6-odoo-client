#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Odoo::Client;

my $odoo = Odoo::Client.new(
    hostname => "localhost",
    port     => 8069
);

# Login to odoo
my $uid = $odoo.login(
    database => "sample", 
    username => 'user@example.com',
    password => "123"
);

say "Version: " ~ $odoo.version.perl;

unless $uid.defined {
    die "Failed to login to odoo";
}

printf("Logged on with user id '%d'\n", $uid);

my $user-model = $odoo.model( 'res.users' );
say $user-model.perl;
my $user-ids = $user-model.search( [] );
say "user-ids: " ~ $user-ids.perl;

unless $user-ids.defined && $user-ids.elems > 0 {
    die "No users! found";
    return;
}

my $user-id = $user-ids[0];
my $user = $user-model.read([$user-id]);
die "Duplicate user id" if $user.elems > 1;
die "User not found!"   if $user.elems == 0;
say "user: " ~ $user[0].perl;

sub create-product($name, $type, $list-price, $image) {
    my $product-model = $odoo.model('product.product');
    return $product-model.create({
        "name"       => $name,
        "type"       => $type,
        "list_price" => $list-price,
        "image"      => $image
    });
}

# Create a product to be sold :)
my $perl6-book-image = "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";
my $product = create-product('Learning Perl 6: The Easy way', 'consu', 29.99, $perl6-book-image);
say $product.perl;
