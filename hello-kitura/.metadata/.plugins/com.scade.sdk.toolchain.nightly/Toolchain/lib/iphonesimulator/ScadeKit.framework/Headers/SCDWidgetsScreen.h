#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsDimension;
@class SCDGraphicsPoint;

typedef NS_ENUM(NSInteger, SCDWidgetsScreenOrientation);
typedef NS_ENUM(NSInteger, SCDWidgetsScreenState);


/*PROTECTED REGION ID(d6fcac3b60a25bdfa953b81a98229601) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsScreen : EObject


@property(nonatomic) NSString* _Nonnull device;

@property(nonatomic) SCDGraphicsDimension* _Nonnull size;

@property(nonatomic) NSString* _Nonnull svg;

@property(nonatomic) SCDGraphicsPoint* _Nonnull location;

@property(nonatomic) SCDGraphicsPoint* _Nonnull landscapeLocation;

@property(nonatomic) SCDWidgetsScreenOrientation orientation;

@property(nonatomic) SCDWidgetsScreenState state;


/*PROTECTED REGION ID(923f0520910faf2ac15d28b4c9934a34) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
