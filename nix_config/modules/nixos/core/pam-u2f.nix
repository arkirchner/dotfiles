{ ... }:
{
  flake.modules.nixos.pam-u2f =
    { pkgs, lib, ... }:
    {
      security.pam.u2f = {
        enable = true;

        settings = {
          interactive = true;
          cue = true;

          origin = "pam://yubi";
          authFile = pkgs.writeText "u2f-mappings" (
            lib.concatStrings [
              "armin"
              ":YOraJfl9LTreqCp+xoW/Xs/yJy+EYo1nc63FjkCXGs7jtZeWHXlw0zWeyrYCfspwZflaPqDlK5s4ZsfUSk4Eqw==,7tBOY1igcf49G+7VXQ0m1E7A4irWnnKhfqQosBJb2TwkYdKAvFM2LkUJKPc613+8FhSfDLyv87LNGFKGAzeFDg==,es256,+presence"
              ":DeJhZjWWn+4IP5/+0wRZOjZHJHvpE9dlybdnVUE7Z7+oXPRfm5MOqSKKxCxXm8uz+4hsXP0s4Da3Mu7r9fx8pA==,9Oq8pLO14qK/9bOu4uLLL+l0gu+iVUNlMv+U2TwN0MvsephwJg75yNWImVT7SsuSeZTnjWnBkidh1Sg2zskzFA==,es256,+presence"
            ]
          );
        };
      };
    };
}
