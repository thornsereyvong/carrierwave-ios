//
//  CRVWhitelistManagerSpec.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 02/02/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVWhitelistManagerSpec)

describe(@"CRVWhitelistManagerSpec", ^{
    
    __block CRVNetworkManager *networkManager;
    
    beforeEach(^{
        networkManager = [CRVNetworkManager sharedManager];
    });
    
    describe(@"on initialization", ^{
        
        __block CRVWhitelistManager *whitelistManager;
        
        beforeAll(^{
            whitelistManager = [[CRVWhitelistManager alloc] init];
        });
        
        it(@"should set whitelist path to default", ^{
            expect(whitelistManager.whitelistPath).to.equal(CRVWhitelistDefaultPath);
        });
        
        it(@"should set whitelist validation time to default", ^{
            expect(whitelistManager.whitelistValidityTime).to.equal(CRVDefaultWhitelistValidity);
        });
        
        afterAll(^{
            whitelistManager = nil;
        });
        
    });
    
    pending(@"whitelist loading");
    
    pending(@"whitelist validation check");
    
    pending(@"whitelist update");
    
    pending(@"whitelist fetching");
    
    pending(@"whitelist synchronization");
    
    afterEach(^{
        networkManager = nil;
    });
    
});

SpecEnd