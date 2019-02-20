#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class EObject;
@class EStructuralFeature;

typedef NS_ENUM(NSInteger, SCDCoreNotificationType);


/*PROTECTED REGION ID(1dace904e62f2670129bbbfb263ebfd3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDCoreNotification : EObject


@property(nonatomic) SCDCoreNotificationType type;

@property(nonatomic) EObject* _Nullable notifier;

@property(nonatomic) EStructuralFeature* _Nullable feature;

@property(nonatomic) id _Nullable newValue;

@property(nonatomic) id _Nullable oldValue;

@property(nonatomic) long position;


/*PROTECTED REGION ID(36d87bc6c5397de00cbe64a7c9a36a96) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
