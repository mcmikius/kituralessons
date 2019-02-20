#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIStyle.h>


@protocol SCDWidgetsIStyle;

@class SCDGraphicsDimension;


/*PROTECTED REGION ID(29f1d78bdf97b16991aa54aef197cfa9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsWidgetStyle : EObject <SCDWidgetsIStyle>


@property(nonatomic) SCDGraphicsDimension* _Nonnull minSize;

@property(nonatomic) SCDGraphicsDimension* _Nonnull maxSize;


/*PROTECTED REGION ID(375746b615a7d5fd8f1368c9652d0f06) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
