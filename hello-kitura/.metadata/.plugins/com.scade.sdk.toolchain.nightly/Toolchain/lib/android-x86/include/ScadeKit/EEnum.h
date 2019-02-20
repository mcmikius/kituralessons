#import <Foundation/Foundation.h>

#import <ScadeKit/EDataType.h>


@class EEnumLiteral;
@class EDataType;


/*PROTECTED REGION ID(96c12f43c8d8a89b845b2e173a9d4ca9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EEnum : EDataType


@property(nonatomic) NSArray<EEnumLiteral*>* _Nonnull eLiterals;


- (EEnumLiteral* _Nullable)getEEnumLiteralWithName:(NSString* _Nonnull)name
    __attribute__((swift_name("getEEnumLiteral(name:)")));

- (EEnumLiteral* _Nullable)getEEnumLiteralWithValue:(long)value
    __attribute__((swift_name("getEEnumLiteral(value:)")));

- (EEnumLiteral* _Nullable)getEEnumLiteralByLiteral:(NSString* _Nonnull)literal;


/*PROTECTED REGION ID(74ff5060693c12fb194bd2e484188320) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
