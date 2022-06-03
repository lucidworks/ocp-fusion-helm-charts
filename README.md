# How to add a new version of Fusion to the list

Pull down previous version of Fusion helm chart and use it to create a diff file to apply using the `patch` linux command. 

Example: 5.4.5

```
TMP_PATH="/tmp"
cd $TMP_PATH
FUSION_VERSION="5.4.5"
helm fetch lucidworks/fusion --version "${FUSION_VERSION}" --untar --untardir fusion-helm-charts
mv fusion-helm-charts/ "${FUSION_VERSION}"
cd "${FUSION_VERSION}"
git init .
git add fusion
git commit -am "initial ${FUSION_VERSION} revision"
rm -rf fusion
cp -r ~/f5/ocp-fusion-helm-charts/${FUSION_VERSION}/fusion .
git commit -am "ocp specific changes on ${FUSION_VERSION} release"
```

Open intellij
Open the folder as a project: `$TMP_PATH/${FUSION_VERSION}/fusion`
Show Git History
Select the "ocp specific changes on ${FUSION_VERSION} release" commit and click "Create patch"
Save patch to updates_for_${FUSION_VERSION}_ocp.patch

Now grab the next version of Fusion from helm and copy it into the git repo.

Example: 5.5.0

```
FUSION_VERSION="5.5.0"
helm fetch lucidworks/fusion --version "${FUSION_VERSION}" --untar --untardir fusion-helm-charts
mv fusion-helm-charts/ ~/f5/ocp-fusion-helm-charts/${FUSION_VERSION}
```

apply the patch

```
cp updates_for_${FUSION_VERSION}_ocp.patch ~/f5/ocp-fusion-helm-charts/${FUSION_VERSION}
cd ~/f5/ocp-fusion-helm-charts/${FUSION_VERSION}
patch -p1 < updates_for_${FUSION_VERSION}_ocp.patch
git add .
git commit -am "ocp specific changes on ${FUSION_VERSION} release"
```

and git Push.