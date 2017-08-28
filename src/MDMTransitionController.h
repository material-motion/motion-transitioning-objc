/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@protocol MDMTransition;

/**
 A transition controller is a bridge between UIKit's view controller transitioning APIs and
 Material Motion transitions.

 Each view controller owns its own transition controller via the mdm_transitionController property.
 */
NS_SWIFT_NAME(TransitionController)
@protocol MDMTransitionController

/**
 A collection of transition objects that will be used to drive a single view controller transition.

 The transition instances will govern any presentation or dismissal of the view controller.

 If no transition instance is provided then a default UIKit transition will be used.

 If any transition conforms to MDMTransitionWithPresentation, then the first such transition's
 default modal presentation style will be queried and assigned to the associated view controller's
 `modalPresentationStyle` property.

 If any transition conforms to MDMTransitionWithCustomDuration, then the each transition's duration
 will queried and the largest value will be used for the overall transition's duration.
 */
@property(nonatomic, copy, nullable) NSArray<id<MDMTransition>> *transitions;

/**
 The active transition instances.

 This may be non-nil while a transition is active.
 */
@property(nonatomic, strong, nullable, readonly) NSArray<id<MDMTransition>> *activeTransitions;

@end
