{
  inputs = {
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    improve = {
      url = "github:shadcn/improve";
      flake = false;
    };
    mattpocock = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    trialofbits = {
      url = "github:trailofbits/skills";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      withAllSkills =
        skillsPath:
        let
          # 1. Read the contents of the target folder.
          # builtins.readDir returns an attribute set like: { "git-skill" = "directory"; "README.md" = "regular"; }
          rawContents = builtins.readDir (builtins.toPath skillsPath);

          # 2. Filter out entries that aren't directories to ensure we ignore root files
          skillDirectories = nixpkgs.lib.filterAttrs (name: type: type == "directory") rawContents;

          # 3. Extract just the names of the directories as a plain list of strings
          skillNames = builtins.attrNames skillDirectories;
        in
        # 4. Map the list of subfolders into a Home Manager attribute set structure
        builtins.listToAttrs (
          map (skillName: {
            name = ".agents/skills/${skillName}";
            value = {
              source = "${skillsPath}/${skillName}";
            };
          }) skillNames
        );
    in
    {
      homeModules.default =
        { config, pkgs, ... }:
        {
          home.file = {
            ".agents/skills/improve-codebase-architecture" = {
              source = "${inputs.mattpocock}/skills/engineering/improve-codebase-architecture";
            };
            ".agents/skills/improve" = {
              source = "${inputs.improve}/skills/improve";
            };
          }
          // (withAllSkills "${inputs.superpowers}/skills");
        };
    };
}
