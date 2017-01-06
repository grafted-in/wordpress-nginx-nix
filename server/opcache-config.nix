# References:
#   * https://www.rfmeier.net/speed-up-wordpress-dreamhost-opcache/
#   * http://us3.php.net/manual/en/opcache.installation.php

{ enabled }:
''
  opcache.enable=${if enabled then "1" else "0"}
  opcache.memory_consumption=128
  opcache.interned_strings_buffer=8  ; The amount of memory to store immutable strings
  opcache.save_comments=1 ; Comments in code will be compiled
  opcache.load_comments=0 ; Comments will not be loaded
  opcache.max_file_size=2097152
  opcache.fast_shutdown=1
  opcache.max_accelerated_files=4000
  opcache.enable_cli=1

  ; Make sure each cached file has a distinct path
  ; See http://php.net/manual/en/opcache.configuration.php#ini.opcache.revalidate-path
  opcache.revalidate_path=1

  ; Check opcace when php uses file checking functions, file_exists, etc
  ; See http://php.net/manual/en/opcache.configuration.php#ini.opcache.enable-file-override
  opcache.enable_file_override=1

  ; Turn off cache experiation.
  ; See http://php.net/manual/en/opcache.configuration.php#ini.opcache.validate-timestamps
  opcache.validate_timestamps=0

  ; How long to check a file if it needs to be re-cached
  ; If opcache.validate_timestamps is disabled, this is ignored.
  ; See http://php.net/manual/en/opcache.configuration.php#ini.opcache.revalidate-freq
  opcache.revalidate_freq=60
''
