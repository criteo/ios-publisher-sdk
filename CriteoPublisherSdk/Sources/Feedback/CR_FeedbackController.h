//
//  CR_FeedbackController.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifndef CR_FeedbackController_h
#define CR_FeedbackController_h

#import <Foundation/Foundation.h>

@class CR_FeedbackStorage;
@class CR_ApiHandler;
@class CR_Config;
@class CR_CdbRequest;
@class CR_CdbResponse;
@class CR_CdbBid;
@class CR_DataProtectionConsent;

/**
 * Update metrics files accordingly to received events.
 *
 * @see Client side metric specification: https://go.crto.in/publisher-sdk-csm
 */
@protocol CR_FeedbackDelegate

/**
 * On CDB call start, each requested slot is tracked by a new metric feedback. The metrics marks the
 * timestamp of this event and wait for further updates.
 *
 * @param request Request sent to CDB
 */
- (void)onCdbCallStarted:(CR_CdbRequest *)request;

/**
 * When the CDB call ends successfully, metrics corresponding to requested slots are updated
 * accordingly to the response.
 *
 * If there is no response for a slot, then it is a no bid. The metric marks the timestamp of this
 * event and, as no consumption of this no-bid is expected, the metric is tagged as finished and
 * ready to send.
 *
 * If there is a matching invalid slot, then it is considered as an error. The metric is not
 * longer updated and is flagged as ready to send.
 *
 * If there is a matching valid slot, then it is a consumable bid. The metric marks the timestamp
 * of this event, and waits for further updates (via consumption).
 *
 * @param response Response coming from CDB
 * @param request Request that was sent to CDB
 */
- (void)onCdbCallResponse:(CR_CdbResponse *)response fromRequest:(CR_CdbRequest *)request;

/**
 * On CDB call failed, metrics corresponding to the requested slots are updated.
 *
 * If the failure is a timeout, then all metrics are flagged as having a timeout.
 *
 * Then, since no further updates are expected, all metrics are flagged as ready to send.
 *
 * @param failure Error representing the failure of the call
 * @param request Request that was sent to CDB
 */
- (void)onCdbCallFailure:(NSError *)failure fromRequest:(CR_CdbRequest *)request;

/**
 * On bid cached, the metric feedback associated to the bid is marked as `cachedBidUsed`
 *
 * @param bid bid that was cached
 */
- (void)onBidCached:(CR_CdbBid *)bid;

/**
 * On bid consumption, the metric feedback associated to the bid is updated.
 *
 * If the bid has not expired, then the bid managed to go from CDB to the user. The metric marks
 * the timestamp of this event.
 *
 * Since this is the end of the bid lifecycle, the metric does not expect further updates and is
 * flagged as ready to send.
 *
 * @param consumedBid bid that was consumed
 */
- (void)onBidConsumed:(CR_CdbBid *)consumedBid;

/**
 * Send asynchronously a new batch of metrics to the CSM backend.
 *
 * This is a fire and forget operation. No output is expected. Although, if an error occurs while
 * sending the metrics to the backend, they are pushed back in the sending queue.
 *
 * The batch is polled from the queue (instead of peeked). Data loss is tolerated if the process
 * is terminated while the batch is being sent to the CSM backed. This is to ensure that the same
 * metric will never be sent to CSM backend twice.
 */
- (void)sendFeedbackBatch;

@end

@interface CR_FeedbackController : NSObject <CR_FeedbackDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFeedbackStorage:(CR_FeedbackStorage *)feedbackStorage
                             apiHandler:(CR_ApiHandler *)apiHandler
                                 config:(CR_Config *)config NS_DESIGNATED_INITIALIZER;

/**
 * Helper method to create a feedback delegate based on a feedback controller but guarded by the CSM
 * feature flag.
 *
 * @param feedbackStorage internal storage used to handle living metrics and queued ready-to-send
 * metrics
 * @param apiHandler handler used to send ready-to-send metrics
 * @param config global config to help the API and enabled/disabled this CSM feature
 * @param consent data protection consent to determine if we're allowed to use CSM feature
 * @return feedback delegate
 */
+ (id<CR_FeedbackDelegate>)controllerWithFeedbackStorage:(CR_FeedbackStorage *)feedbackStorage
                                              apiHandler:(CR_ApiHandler *)apiHandler
                                                  config:(CR_Config *)config
                                                 consent:(CR_DataProtectionConsent *)consent;

@end

#endif /* CR_FeedbackController_h */
