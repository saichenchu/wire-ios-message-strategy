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

import Foundation
import WireRequestStrategy

public class GenericMessageEntity : OTREntity {
    
    public var message : ZMGenericMessage
    public var conversation : ZMConversation?
    public var completionHandler : ((_ response: ZMTransportResponse) -> Void)?
    public var isExpired: Bool = false
    
    init(conversation: ZMConversation, message: ZMGenericMessage, completionHandler: ((_ response: ZMTransportResponse) -> Void)?) {
        self.conversation = conversation
        self.message = message
        self.completionHandler = completionHandler
    }
    
    public var dependentObjectNeedingUpdateBeforeProcessing: AnyObject? {
        return self.dependentObjectNeedingUpdateBeforeProcessingOTREntity()
    }
    
    public func missesRecipients(_ recipients: Set<UserClient>!) {
        // no-op
    }
    
    public func expire() {
        isExpired = true
    }
}

extension GenericMessageEntity : EncryptedPayloadGenerator {
    
    public func encryptedMessagePayloadData() -> (data: Data, strategy: MissingClientsStrategy)? {
        return message.encryptedMessagePayloadData(conversation!, externalData: nil)
    }
    
    public var debugInfo: String {
        return "\(self)"
    }
    
}

/// This should not be used as a standalone strategy but either subclassed or used within another
/// strategy. Please have a look at `CallingRequestStrategy` and `GenericMessageNotificationRequestStrategy`
/// before modifying the behaviour of this class.
public class GenericMessageRequestStrategy : OTREntityTranscoder<GenericMessageEntity>, ZMRequestGenerator, ZMContextChangeTracker {
    
    private var sync : DependencyEntitySync<GenericMessageRequestStrategy>?
    private var requestFactory = ClientMessageRequestFactory()
    
    public override init(context: NSManagedObjectContext, clientRegistrationDelegate: ClientRegistrationDelegate) {
        super.init(context: context, clientRegistrationDelegate: clientRegistrationDelegate)
        
        sync = DependencyEntitySync(transcoder: self, context: context)
    }
    
    public func schedule(message: ZMGenericMessage, inConversation conversation: ZMConversation, completionHandler: ((_ response: ZMTransportResponse) -> Void)?) {
        sync?.synchronize(entity: GenericMessageEntity(conversation: conversation, message: message, completionHandler: completionHandler))
        RequestAvailableNotification.notifyNewRequestsAvailable(nil)
    }
    
    public func expireEntities(withDependency dependency: AnyObject) {
        sync?.expireEntities(withDependency: dependency)
    }
    
    public override func request(forEntity entity: GenericMessageEntity) -> ZMTransportRequest? {
         return requestFactory.upstreamRequestForMessage(entity, forConversationWithId: entity.conversation!.remoteIdentifier!)
    }
    
    public override func shouldTryToResend(entity: GenericMessageEntity, afterFailureWithResponse response: ZMTransportResponse) -> Bool {
        entity.completionHandler?(response)
        return super.shouldTryToResend(entity: entity, afterFailureWithResponse: response)
    }
    
    public override func request(forEntity entity: GenericMessageEntity, didCompleteWithResponse response: ZMTransportResponse) {
        super.request(forEntity: entity, didCompleteWithResponse: response)
        
        entity.completionHandler?(response)
    }
    
    public func nextRequest() -> ZMTransportRequest? {
        return sync?.nextRequest()
    }
    
    public func objectsDidChange(_ object: Set<NSManagedObject>) {
        sync?.objectsDidChange(object)
    }
    
    public func fetchRequestForTrackedObjects() -> NSFetchRequest<NSFetchRequestResult>? {
        return sync?.fetchRequestForTrackedObjects()
    }
    
    public func addTrackedObjects(_ objects: Set<NSManagedObject>) {
        sync?.addTrackedObjects(objects)
    }
}
