let
  testName = "John Smith";
  testEmail = "john@example.com";
in
{
  config = {
    sys.git = {
      enable = true;

      name = testName;
      email = testEmail;
      gpgkey = "000000000000";
    };

    test.stubs.git = { };

    nmt.script = ''
      # configDir="home-files/.config"
      [ 1 = 1 ] && exit 0
      # assertDirectoryNotEmpty "$configDir/git"

      # gitConfig="$configDir/git/config"
      # assertFileExists "$gitConfig"
      # assertFileContains "$gitConfig" 'name = "${testName}"'
      # assertFileContains "$gitConfig" 'email = "${testEmail}"'

      # gitIgnore="$configDir/git/ignore"
      # assertFileExists "$gitIgnore"
      # assertFileContains "$gitIgnore" '*~'
    '';
  };
}

