
Various ways I screwed up:

- did not install pico compiler first
- used a project name with a dash
- wrote 'piconim build src/projname.name' instead of 'piconim build projname'

Doc improvement

- just write already the file is csource/build/sesame.uf2


Should make PRs for these


---

okay so most of the cmake build is hidden behind the piconim tool and there is a macro mechanism to auto-supply dependencies which does not seem to work with raspico w- module cannot be derived from path.

