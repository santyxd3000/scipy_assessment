# Revelo's Assessment

Do **NOT** open pull requests to this repository. If you do, your application will be immediately discarded.

## Thoughts

- 17:08: I started this assessment by having a look at the project and all the files, as well as the issue created

- 17:09: I tried dockerizing the file, and found some errors related to installing dependencies, I ran this code `docker run --rm -it $(docker build -q .)`
- 17:12:  – I started with the original Dockerfile using python:3.12-slim and basic dependency installation.

- 17:20:  – I modified the apt-get install block to include more build dependencies but introduced a syntax error by breaking the line incorrectly.
  
- 17:35: – I adjusted the pip install commands, removing --use-pep517, but later hit SciPy Fortran compilation errors.

- 17:50: – I attempted to apply fix.patch, but it failed because the target files had diverged from the patch’s expected state.

- 18:05 – I tried to regenerate or replace the patch but mixed in unrelated files, causing git apply errors, solved it finally with the `git apply -C1 --check fix.patch` command
