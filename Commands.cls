/*VS STUIO CODE */
ctrl+shift+L : select all and change for all.
ctrl+p : serach a file .

/* GIT COMMAND */

//configure git 

    git config  user.email ''
    git config  user.name  ''
//clone git respository data in to folder
cd d:
mkdir CFOMO
cd CFOMO

//git issue use https instead of SSH
git clone https://github.com/sumit786/forcedeveloperblog.git;
cd projectname
git branch dev

//view all the branch and * current working branch
git branch 

//create a new branch based on a another branch
git branch -b newbranch sourcebranch

//switch to another branch

    //switch to the branch
    git checkout branchanme

    //check current branch
    git branch

//add file to branch
git add filename1, ... ...

//commit file to a branch
git commit -m 'comment'

//add and commit in one step
git commit -am filename1

//push a branch to git
git push origin branchname

//merge branch in git
    //move to target branch master
    git checkout master
    //check are you in a right branch
    git branch
    //merge the branch
    git merge branchname(dev)
    //push code to master branch
    git push origin dev:master

//track if any change happened

    git merge dev
    git pull