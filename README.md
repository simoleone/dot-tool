# Dot Tool
Yet another dot file manager. Batteries not included (BYO actual dot files).

# Why?
Because I'm a nerd and I felt like it.

# Dependencies
Bash, Bash, and probably some more Bash.

# How does it work?
## Getting started
1. Fork this repo.
2. Check your dot files into the `dotfiles` directory in your fork as if it was your home directory.

## Getting your dot files on a new machine
1. Clone your fork to your machine.
2. `dot_tool.sh -a update`

## Updating your dot files
1. Pull your fork
2. `dot_tool.sh -a update`

# Is this thing safe?
I make no warranties, but I use it myself and I've only regretted it once or twice so far ;)

Additionally, you might consider:
* It's like ~100 lines of bash. You can read the source code for yourself easily enough.
* There is a dry run mode (`-d`) that you can use to see changes before they happen.
* The script will back up any files it's going to change (it saves them with a `.dotfilesbak` extension). Beware: new backups simply
blow away old backups.
* If you find something you'd like to change, just send a PR!

# Other pro-tips
* This is a symlink-based system, so when you git pull your fork, your dot-files get updated (unless you've added new ones or removed something, in which case you can just run the update script again).
* Since it's all symlinked, you can get your dot files to magically sync across machines by cloning your fork to Dropbox or Google Drive, and updating from there. Heck, you could keep your ssh known hosts or bash history across machines that way if you chose to.
