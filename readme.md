# Criteo Direct Bidder for Google Mediation

## Publication on Github and CocoaPods

### Publication on Github

The following script will prepare the publication:

    ./scripts/prepare_publication_on_github.sh <new version> "<Commit message>"

Example:

    ./scripts/prepare_publication_on_github.sh 3.4.1.0 "Set Google's consent into the Criteo Publisher SDK"

Then you need to go in the created directory, review the result and push if it fits you.
For that check the command suggested by the script and don't forget to push the new tag.

### Publication on Cocoapods

Update the CriteoGoogleMediationAdapters.podspec with the version.
The following script will push the new version on Cocoapods:

    ./scripts/publish_on_cocoapods.sh

---------------------------------
/!\ This script hasn't been tested on this project because it pushes directly
on CocoaPods. It is a copied/pasted/adjusted from the Mopub adaptor's script.
So use it with caution the first time and then remove this comment.
---------------------------------
