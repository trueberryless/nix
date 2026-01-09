{ ... }: {
  launchd.user.agents.clipbook = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Clipbook.app/Contents/MacOS/Clipbook" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
