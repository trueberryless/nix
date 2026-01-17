{ ... }: {
  launchd.user.agents.clipbook = {
    serviceConfig = {
      ProgramArguments = [ "/Applications/Clipbook.app/Contents/MacOS/Clipbook" ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
