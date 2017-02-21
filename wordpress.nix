{ fetchzip, runCommand, ... }:
let
  version = "4.7.2";
in fetchzip {
  url = "https://wordpress.org/wordpress-${version}.tar.gz";
  sha256 = "0im54f83q9adskjq9m1jnwsb8vrb2pwav5m4nj4vsbrapvbzh9m6";
}
