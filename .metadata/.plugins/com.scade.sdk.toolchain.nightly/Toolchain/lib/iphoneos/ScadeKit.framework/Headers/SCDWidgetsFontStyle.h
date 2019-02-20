#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIStyle.h>


@protocol SCDWidgetsIStyle;

@class SCDGraphicsRGB;


/*PROTECTED REGION ID(b80fd30c7ad0058f52e25979447fbdf3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsFontStyle : EObject <SCDWidgetsIStyle>


@property(nonatomic) NSString* _Nonnull fontFamily;

@property(nonatomic) long size;

@property(nonatomic, getter=isBold) BOOL bold;

@property(nonatomic, getter=isItalic) BOOL italic;

@property(nonatomic, getter=isLineThrough) BOOL lineThrough;

@property(nonatomic, getter=isUnderline) BOOL underline;

@property(nonatomic) SCDGraphicsRGB* _Nonnull color;


/*PROTECTED REGION ID(81d18e18640461bb825c182f2f826bb0) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
