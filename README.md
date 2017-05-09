# Introduction
Vincent Driessen's [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/) has helped countless teams standardize process with respect to utilizing Git ... without his intial work subsequent [discussion](http://endoflineblog.com/gitflow-considered-harmful) and follow-up [discussion](http://endoflineblog.com/follow-up-to-gitflow-considered-harmful) would not be possible.

[OneFlow](http://endoflineblog.com/oneflow-a-git-branching-model-and-workflow) addresses many of the challenges identified with GitFlow.  At the end of the day, the power in these approaches is the standard use of Git within a team environment - the good news is that there are many great workflows available when using Git - pick what works best in context of your particular objective(s) and team(s)!

## This Project
This project seeks to emdody the goodness of OneFlow in four core Git aliases `bnew`, `bup`, `bpush`, and `bdone`.  We've had success getting team members new to Git up and running quickly - of course the ultimate goal is to produce a level of proficiency where team members understand what the scripts are doing such that they are not needed but simply a creature comfort.

## Getting Started
1.	Clone this repo
2.	On *nix run `make-gitconfig.sh` - take a look a the local .gitconfig - to make changes to your global .gitconfig run `make-gitconfig.sh -g`. On Windows run `make-gitconfig.ps1` and/or `make-gitconfig.ps1 -g` respectively.

## Basic Workflow
* Initial clone
    1. `git clone repo`
    2. `git checkout develop`
* Feature work
    1. `git bnew -f “A Short Description”`
    2. `git commit -am “A shortish (50 character) commit message”`
* Periodically make sure you are up to date with the remote and resolve any merge conflicts early!
    1. `git bup or bfresh [-r]`
* At the end of the day make sure your work is on the remote
    1. `git bpush or bsaved [-r]`
* Create a PR when your code is a candidate to be merged into develop and you are ready for a code review
* After the PR has been merged into develop
    1. `git bdone`

## Todo
1. Potentially more switches -  for example make minimal changes to .gitconfig, etc
2. brelease
3. ...
