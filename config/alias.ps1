 Param (
    [parameter(Mandatory=$true)]
    [string] $1
)

git config --file "$1" alias.ec 'config --global -e'
git config --file "$1" alias.amend 'commit --amend'
git config --file "$1" alias.br 'branch'
git config --file "$1" alias.caa 'commit -a --amend -C HEAD'
git config --file "$1" alias.ci 'commit -m'
git config --file "$1" alias.co 'checkout'
git config --file "$1" alias.cob 'checkout -b'
git config --file "$1" alias.cp 'cherry-pick'
git config --file "$1" alias.cpa 'cherry-pick --abort'
git config --file "$1" alias.cpc 'cherry-pick --continue'
git config --file "$1" alias.unstage 'reset HEAD'
git config --file "$1" alias.rba 'rebase --abort'
git config --file "$1" alias.rbc 'rebase --continue'
git config --file "$1" alias.rbs 'rebase --skip'
git config --file "$1" alias.logbase "log --pretty='%C(bold blue)%h%C(reset) |%C(auto)%d%C(reset) %C(white)%s%C(reset) %C(bold yellow)(%ar) on (%aD)%C(reset) %C(bold cyan)[%an]%C(reset)'"
git config --file "$1" alias.st 'status'
git config --file "$1" alias.pushf 'push --force-with-lease'
git config --file "$1" alias.pusht 'push --follow-tags'
