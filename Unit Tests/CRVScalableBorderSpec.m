//
//  CRVScalableBorderSpec.m
//  Carrierwave
//
//  Created by Paweł Białecki on 03.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVScalableBorderSpec)

describe(@"CRVScalableBorderSpec", ^{
    
    __block CRVScalableBorder *scalableBorder = nil;
    
    context(@"when newly created", ^{
        
        beforeEach(^{
            CGRect frame = CGRectMake(100, 100, 100, 100);
            scalableBorder = [[CRVScalableBorder alloc] initWithFrame:frame];
        });
        
    });
    
});

SpecEnd
