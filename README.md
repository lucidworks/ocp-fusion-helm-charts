# Helm Charts that work on OpenShift

Here we maintain minor changes to our helm charts to make them work on on-prem openshift.

## How to add a new version of Fusion to the list

Open Pycharm (or intellij)

Add the new helm chart folder, example 5.4.2 to and commit it, push it.

Open up the Git history of the previous folder, example 5.4.1

Select all the changes and right click "create patch"

Change the relative location to the 5.4.1 folder.

Create the patch (takes a bit)

Open a git bash terminal and cd to the new folder, example 5.4.2.

Run the patch file "patch -p0 < patchfile.patch"

Commit / Push.
