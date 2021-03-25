Everybody is encouraged to update and maintain our repositories. To ensure good quality and minimum debugging struggles, these guidelines must be observed:

## branching

Before starting to work on a repository, create a branch: your_name/what_you_will_work_on.

For example: vberenz/adding_eigen_support

Work on this branch and push as many commits as you wish.

## code update

When you update code, you must also:

- update the unit tests, create new unit tests if necessary
- update the demos, create new demos if necessary
- update the doxygen documentation
- format your code

see this [page](07_Writing-cpp-code) for more details

## squashing

It is good manner to squash all the commits of the branch before a code review (see below), as this makes the work of the reviewer easier.

See for example these [instructions](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)

## perform a pull request 

- After pushing your branch to origin, visit the repository on github and create a pull request. 
- Add at least a reviewer. Two reviewers is better. Select in priority someone in the lab who is using the code, someone else otherwise.
- Add yourself as assignees. 
- Select an appropriate label.
- Provide a description of the update, and confirm that:
    - you updated the unit tests
    - you updated the demos
    - you updated to doc
    - you applied the format
- Describe how you tested the code you are pushing work (if for some valid reason you did not update the unit tests).

## enjoy the review

The code review interface of Github is quite straightforward

## merge

Once the pull request approved, merge your branch (this can be done directly from the github pull request page)

## delete the branch

see this [page](https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/)

## if you are reviewer

If you review some update, at minima you must check that all the guidelines has been followed (unit tests, demos, documentation, formatting). 

Check if you see any way the code could be improved, or if you see some errors.

To avoid :
- request for micro-optimization
- request for changes somehow arbitrary (would result in same performance, but you would find the code more beautiful based on subjective criteria)
- request for further change ("it would be nice to also have ...". One could argue you can do it yourself).





