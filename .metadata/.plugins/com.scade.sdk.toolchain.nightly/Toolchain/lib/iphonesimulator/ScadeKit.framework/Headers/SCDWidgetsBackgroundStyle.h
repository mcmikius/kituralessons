#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIStyle.h>


@protocol SCDWidgetsIStyle;

@class SCDGraphicsRGB;

typedef NS_ENUM(NSInteger, SCDWidgetsBackgroundType);


/*PROTECTED REGION ID(9a9c48d49eade2e4cd03e1bed8ee2a76) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsBackgroundStyle : EObject <SCDWidgetsIStyle>


@property(nonatomic) SCDGraphicsRGB* _Nonnull color;

@property(nonatomic) NSString* _Nonnull image;

@property(nonatomic) SCDWidgetsBackgroundType type;


/*PROTECTED REGION ID(0941babb0bb6753fabb012e2a929a9e7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
