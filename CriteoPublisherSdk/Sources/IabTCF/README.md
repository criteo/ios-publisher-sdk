# IAB-TCF-V2-Objective-C
IAB Transparency and Consent Framework consent string decoder in Objective-C (and by extension in Swift) compliant with both IAB TCF mobile [v1.1](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Consent%20string%20and%20vendor%20list%20formats%20v1.1%20Final.md) & [v2.0](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20Consent%20string%20and%20vendor%20list%20formats%20v2.md#tc-string-format), for any IABConsentString

## Usage
### 1.Copy files
Copy all files in your project.

### 2.Use case
<a id="readingConsent"></a>
#### 1. Reading consent from a localy stored Transparency Consent String (TCString)

The following API methods give everything needed to interpret the consent from the localy stored TCString.
```Objective-C
#import "SPTIabTCFApi.h"
...

    SPTIabTCFApi *iabAPI = [SPTIabTCFApi new];
    
    [iabAPI isVendorConsentGivenFor:<VendorId>];
    [iabAPI isVendorLegitimateInterestGivenFor:<VendorId>];
    
    [iabAPI isPurposeConsentGivenFor:<PurposeId>];
    [iabAPI isPurposeLegitimateInterestGivenFor:<PurposeId>];
    
    [iabAPI isPublisherPurposeConsentGivenFor:<PurposeId>];
    [iabAPI isPublisherPurposeLegitimateInterestGivenFor:<PurposeId>];
    [iabAPI isPublisherCustomPurposeConsentGivenFor:<PurposeId>];
    [iabAPI isPublisherCustomPurposeLegitimateInterestGivenFor:<PurposeId>];
    
    [iabAPI isSpecialFeatureOptedInFor:<FeatureId>];
```
***Notes*** :
* Methodes `isVendorConsentGivenFor` and `isPurposeConsentGivenFor` are looking for v2 **AND** v1 TC strings and interpreting consents from both prioritizing v2 (if the two are present). If v1 need to be ignored an argument `ignoreV1` can be set as follow (from previous code exemple): `iabAPI.ignoreV1 = YES`.
* All consents are directly read from the consent string (rather than from IAB storing keys - [c.f. here](#settingATCSString) - for more consistancy). Indeed from the experience of v1 mobile, not all CMP used to set all the keys, and the decoder is fast enought 😉. 

<a id="settingATCSString"></a>
#### 2. Setting a TCString

To officially comply with IAB Transparency and Consent Framework (TCF) mobile, decoded parts of the TC string must be stored localy in `[NSUserDefaults standartUserDefault]` under precise keys defined [here for v1](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-) and [there for v2](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-is-the-cmp-in-app-internal-structure-for-the-defined-api)
Fortunatly our API does it all for you simply by setting the new TCString : 
```Objective-C
    [[SPTIabTCFApi new] setConsentString: <newTCString>];
```
IAB TCF version is automatically detected and everything is stored at the right place. You can then read the new stored consent using code from paragraph above.

`SPTIabTCFApi`also allows to manually set each and every value of decoded parts of the consent string if needed.


#### 3. Decoding a TCString

Sometime reading consents from a TCString is needed without necessarily storing the string itself. 
Use the following code to obtain a model with all the property of IAB Transparency and Consent Framework v1.1 or v2

```Objective-C
SPTIabTCFModel *model = [[SPTIabTCFApi new] decodeTCString:<aTCString>];
```
This model has the same methods as defined in [1. Reading consent from a localy stored TCString](#readingConsent) to interpret consents.


## Improvement 🚀 
- A coder if needed (or if someone wants to do it 😊)

