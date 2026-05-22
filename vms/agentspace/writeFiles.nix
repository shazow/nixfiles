{
  "/home/agent/.codex/auth.json" = {
    chown = "agent:users";
    mode = "0600";
    path = "/home/shazow/.config/codex/auth.json";
    writeBack = true;
  };
  "/home/agent/.codex/config.toml" = {
    chown = "agent:users";
    mode = "0600";
    text = # toml
      ''
      service_tier = "fast"

      [projects."/home/agent/workspace"]
        trust_level = "trusted"

      [plugins."github@openai-curated"]
        enabled = true

      [notice]
        fast_default_opt_out = true

      [tui]
        notification_method = "bel"
      '';
  };
}
