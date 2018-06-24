## Heart

[![Build Status](https://travis-ci.com/mchirico/heart.svg?branch=develop)](https://travis-ci.com/mchirico/heart)

<a href='https://jira.aipiggybot.io/projects/HR/issues/DP-1?filter=allopenissues'>
<img src="https://storage.googleapis.com/montco-stats/JiraSoftware.png" alt="drawing" width="150px;"/>
         </a>

## Note:

You will need to create your own `GoogleService-Info.plist` file from
Firebase.

## Travis-ci

Note **xcodebuild test** should not include the `CODE_SIGNING_REQUIRED=NO` that's only needed in **xcodebuild clean build**.  See the `.travis.yml` for a clear explaination. 

Below is a quick video on setting up shared scheme for travis-ci testing.

<iframe src="https://player.vimeo.com/video/276763767" width="640" height="360" frameborder="0" allowfullscreen></iframe>


