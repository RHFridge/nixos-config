# Workaround: the libnotify backport (nixpkgs#569595 / #573782) makes Solaar's
# notification tests try to reach a D-Bus session bus, which the build sandbox
# doesn't have. Remove once fixed upstream.
final: prev: {
  solaar = prev.solaar.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [ "test_show" ];
  });
}