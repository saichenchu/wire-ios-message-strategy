// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


#import "MessagingTest.h"

@class ZMMessageTranscoder;
@class ZMUser;
@class ZMUpstreamInsertedObjectSync;

@interface ZMMessageTranscoderTests : MessagingTest {
    ZMMessageTranscoder *_sut;
}

@property (nonatomic) ZMMessageTranscoder *sut;
@property (nonatomic) ZMUser *user1;
@property (nonatomic) ZMUser *selfUser;

@property (nonatomic) ZMUpstreamInsertedObjectSync *upstreamObjectSync;

@property (nonatomic) id notificationDispatcher;
@property (nonatomic) id mockExpirationTimer;
@property (nonatomic) id mockAppStateDelegate;

- (ZMConversation *)insertGroupConversation;
- (ZMConversation *)insertGroupConversationInMoc:(NSManagedObjectContext *)moc;

@end

