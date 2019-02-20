#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIStyle.h>


@protocol SCDWidgetsIStyle;


typedef NS_ENUM(NSInteger, SCDLayoutHorizontalAlignment);
typedef NS_ENUM(NSInteger, SCDWidgetsBaselineAlignment);
typedef NS_ENUM(NSInteger, SCDLayoutVerticalAlignment);


/*PROTECTED REGION ID(12446719035c4b4700d946e4e7e33938) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTextStyle : EObject <SCDWidgetsIStyle>


@property(nonatomic) SCDLayoutHorizontalAlignment horizontalAlignment;

@property(nonatomic) SCDWidgetsBaselineAlignment baselineAlignment;

@property(nonatomic) SCDLayoutVerticalAlignment verticalAlignment;


/*PROTECTED REGION ID(013c0c2abe7578a9f79a7cd44431ee7c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
