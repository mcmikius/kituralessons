#import <Foundation/Foundation.h>

#import <ScadeKit/SCDLatticePoint.h>


@class SCDLatticeChanel;
@class SCDLatticePoint;


/*PROTECTED REGION ID(90b7349b53504b5b5625a7c5f71d1091) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeExitPoint : SCDLatticePoint


@property(nonatomic) SCDLatticeChanel* _Nullable outcoming;


- (void)go __attribute__((swift_name("go()")));

- (void)goWithData:(id _Nullable)data __attribute__((swift_name("go(data:)")));


/*PROTECTED REGION ID(d552d25d0a52148189a16d49013e1a4e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
