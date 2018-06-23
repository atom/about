### Requirements

* Filling out the template is required. Any pull request that does not include enough information to be reviewed in a timely manner may be closed at the maintainers' discretion.
* All new code requires tests to ensure against regressions

### Description of the Change

I've added the information provided via `atom -v` on the command line to the About page, as suggested here: https://github.com/atom/atom/issues/17547

The about page already provides the Atom version, I simply use the process.versions helper to get the Electron and Chrome versions, and the process.version to get the Node version. 

These are shown by clicking a `Show more` link directly below the existing atom version number, and are smaller in order to not clutter up the design. 

### Alternate Designs

I at first just had the new version numbers shown by default directly below the Atom version, in the same font size, and this looked cluttered and busy. I decided since it was extra info and only useful to a subset of people, I'd put it behind a `Show more` button. This prevents cluttering the view, but allows additional useful information if desired. 

### Benefits

This change will give people the ability to quickly view the current versions of Electron, Chrome and Node being used in their build of Atom without having to open a terminal, and is more discoverable than a terminal command. 

### Possible Drawbacks

I haven't noticed any drawbacks in my testing, and no changes in performance of the About page when opening or reloading. It doesn't hide any existing info or add steps to get to existing info, so those who don't need / want the additional version numbers provided won't notice a difference. 

### Applicable Issues

n/a
