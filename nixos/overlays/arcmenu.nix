/* (self: super: {
	gnomeExtensions = super.gnomeExtensions // {
		arcmenu = super.gnomeExtensions.arcmenu.overrideDerivation (old: {
			version = "19";
			src = super.fetchFromGitLab {
				owner = "arcmenu";
				repo = "ArcMenu";
				rev = "v${super.gnomeExtensions.arcmenu.version}";
				sha256 = "sha256-GEeONrrH00Tt9tuxhH7Gv5lSZ2D/hFgeGbUstqJsWZo=";
			};
		});
	};
})
*/
