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

@import WireRequestStrategy;

typedef NS_ENUM(NSInteger, ZMAppState){
    ZMAppStateUnauthenticated,
    ZMAppStateSyncing,
    ZMAppStateEventProcessing
};

typedef NS_OPTIONS(NSInteger, ZMStrategyConfigurationOption) {
    ZMStrategyConfigurationOptionDoesNotAllowRequests = 0,
    ZMStrategyConfigurationOptionAllowsRequestsWhileUnauthenticated = 1 << 0,
    ZMStrategyConfigurationOptionAllowsRequestsDuringSync = 1 << 1,
    ZMStrategyConfigurationOptionAllowsRequestsDuringEventProcessing = 1 << 2,
};


@protocol ClientDeletionDelegate <NSObject>
- (void)didDetectCurrentClientDeletion;
@end


@protocol ZMAppStateDelegate
@property (nonatomic, readonly) ZMAppState appState;
@property (nonatomic, readonly, nonnull) id<DeliveryConfirmationDelegate> confirmationDelegate;
@property (nonatomic, readonly, nonnull) id<ClientDeletionDelegate> clientDeletionDelegate;
@property (nonatomic, readonly, nonnull) id<ZMRequestCancellation> taskCancellationDelegate;
@end



@interface ZMAbstractRequestStrategy : NSObject <ZMRequestGenerator>

- (nonnull instancetype)initWithManagedObjectContext:(NSManagedObjectContext* _Nonnull)moc
                            appStateDelegate:(id<ZMAppStateDelegate> _Nonnull)appStateDelegate;

/// Subclasses must override this method;
- (nullable ZMTransportRequest *)nextRequestIfAllowed;

- (void)tearDown;

@property (nonatomic, readonly, nonnull) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak, readonly, nullable) id<ZMAppStateDelegate> appStateDelegate;
@property (nonatomic, readonly) ZMStrategyConfigurationOption configuration;

@end


